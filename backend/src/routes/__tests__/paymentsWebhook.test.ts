import { Request, Response } from "express";
import Stripe from "stripe";

// Set required env vars before imports
process.env.STRIPE_SECRET_KEY = "sk_test_dummy";
process.env.STRIPE_WEBHOOK_SECRET = "whsec_dummy";

// Mock function holders
const mockTransactionUpdateMany = jest.fn();
const mockTransactionFindFirst = jest.fn();
const mockFeeRevenueCreate = jest.fn();
const mockAuditLogCreate = jest.fn();
const mockBalanceTransactionRetrieve = jest.fn();
const mockWebhooksConstructEvent = jest.fn();
const mockSocketEmit = jest.fn();
const mockSocketTo = jest.fn().mockReturnValue({ emit: mockSocketEmit });

// Mock Stripe
jest.mock("stripe", () => {
  return jest.fn().mockImplementation(() => ({
    webhooks: {
      constructEvent: (...args: any[]) => mockWebhooksConstructEvent(...args),
    },
    balanceTransactions: {
      retrieve: (...args: any[]) => mockBalanceTransactionRetrieve(...args),
    },
  }));
});

// Mock Socket.IO
const mockIO = {
  to: mockSocketTo,
} as any;

// Mock logger
jest.mock("../../logger", () => ({
  __esModule: true,
  default: {
    error: jest.fn(),
    warn: jest.fn(),
    info: jest.fn(),
  },
}));

// Import handler and set injected prisma client explicitly
import { handleStripeWebhook, setPaymentsSocketIO } from "../paymentsWebhook";
// Directly import and mock the prisma instance used by webhook handler
const paymentsWebhookModule = require("../paymentsWebhook");
jest.spyOn(paymentsWebhookModule, "default");

// Replace runtime prisma with our mocks by monkey-patching the imported module
const prismaClient = require("../../prismaClient").default;
prismaClient.transaction = {
  updateMany: mockTransactionUpdateMany,
  findFirst: mockTransactionFindFirst,
};
prismaClient.feeRevenue = {
  create: mockFeeRevenueCreate,
};
prismaClient.auditLog = {
  create: mockAuditLogCreate,
};

describe("Stripe Webhook Handler", () => {
  let mockReq: Partial<Request>;
  let mockRes: Partial<Response>;
  let jsonSpy: jest.Mock;
  let sendSpy: jest.Mock;
  let statusSpy: jest.Mock;

  beforeEach(() => {
    jest.clearAllMocks();
    jsonSpy = jest.fn();
    sendSpy = jest.fn();
    statusSpy = jest.fn().mockReturnThis();

    mockReq = {
      headers: { "stripe-signature": "test_signature" },
      body: Buffer.from("test_body"),
    };

    mockRes = {
      json: jsonSpy,
      send: sendSpy,
      status: statusSpy,
    };

    // Inject socket
    setPaymentsSocketIO(mockIO);
  });

  describe("payment_intent.succeeded", () => {
    test("updates transaction, creates fee record and audit log", async () => {
      const mockEvent: Stripe.Event = {
        id: "evt_test",
        object: "event",
        type: "payment_intent.succeeded",
        data: {
          object: {
            id: "pi_succeeded",
            object: "payment_intent",
            amount: 5000,
            currency: "usd",
            description: "Test payment",
            charges: {
              object: "list",
              data: [
                {
                  id: "ch_test",
                  object: "charge",
                  balance_transaction: "txn_balance",
                } as any,
              ],
            },
          } as Stripe.PaymentIntent,
        },
      } as any;

      mockWebhooksConstructEvent.mockReturnValue(mockEvent);
      mockBalanceTransactionRetrieve.mockResolvedValue({
        id: "txn_balance",
        fee: 145,
        net: 4855,
      });
      mockTransactionUpdateMany.mockResolvedValue({ count: 1 });
      mockTransactionFindFirst.mockResolvedValue({
        id: "tx_123",
        userId: "user_1",
        amount: 50.0,
        currency: "USD",
        orderId: "pi_succeeded",
        type: "payment_intent",
      });

      await handleStripeWebhook(mockReq as Request, mockRes as Response);

      expect(mockTransactionUpdateMany).toHaveBeenCalledWith({
        where: {
          orderId: "pi_succeeded",
          provider: "stripe",
          status: "pending",
        },
        data: { status: "completed", description: "Test payment" },
      });

      expect(mockFeeRevenueCreate).toHaveBeenCalledWith({
        data: expect.objectContaining({
          transactionId: "tx_123",
          userId: "user_1",
          flatFee: 1.45,
          totalFee: 1.45,
          netAmount: 48.55,
        }),
      });

      expect(mockAuditLogCreate).toHaveBeenCalledWith({
        data: expect.objectContaining({
          userId: "user_1",
          action: "payment_intent_completed",
          resourceType: "payment_intent",
          resourceId: "pi_succeeded",
        }),
      });

      expect(mockSocketTo).toHaveBeenCalledWith("user-user_1");
      expect(mockSocketEmit).toHaveBeenCalledWith("payment-status", {
        orderId: "pi_succeeded",
        status: "completed",
        amount: 50.0,
        currency: "USD",
      });

      expect(jsonSpy).toHaveBeenCalledWith({ received: true });
    });
  });

  describe("payment_intent.payment_failed", () => {
    test("updates transaction to failed and creates audit log", async () => {
      const mockEvent: Stripe.Event = {
        id: "evt_test",
        object: "event",
        type: "payment_intent.payment_failed",
        data: {
          object: {
            id: "pi_failed",
            object: "payment_intent",
            last_payment_error: {
              message: "Card declined",
            },
          } as Stripe.PaymentIntent,
        },
      } as any;

      mockWebhooksConstructEvent.mockReturnValue(mockEvent);
      mockTransactionUpdateMany.mockResolvedValue({ count: 1 });
      mockTransactionFindFirst.mockResolvedValue({
        id: "tx_456",
        userId: "user_2",
        amount: 100.0,
        currency: "USD",
        orderId: "pi_failed",
      });

      await handleStripeWebhook(mockReq as Request, mockRes as Response);

      expect(mockTransactionUpdateMany).toHaveBeenCalledWith({
        where: { orderId: "pi_failed", provider: "stripe", status: "pending" },
        data: { status: "failed", description: "Card declined" },
      });

      expect(mockAuditLogCreate).toHaveBeenCalledWith({
        data: expect.objectContaining({
          userId: "user_2",
          action: "payment_intent_failed",
          resourceId: "pi_failed",
          metadata: { error: "Card declined" },
        }),
      });

      expect(mockSocketEmit).toHaveBeenCalledWith("payment-status", {
        orderId: "pi_failed",
        status: "failed",
        amount: 100.0,
        currency: "USD",
      });

      expect(jsonSpy).toHaveBeenCalledWith({ received: true });
    });
  });

  describe("payment_intent.canceled", () => {
    test("updates transaction to canceled and creates audit log", async () => {
      const mockEvent: Stripe.Event = {
        id: "evt_test",
        object: "event",
        type: "payment_intent.canceled",
        data: {
          object: {
            id: "pi_canceled",
            object: "payment_intent",
          } as Stripe.PaymentIntent,
        },
      } as any;

      mockWebhooksConstructEvent.mockReturnValue(mockEvent);
      mockTransactionUpdateMany.mockResolvedValue({ count: 1 });
      mockTransactionFindFirst.mockResolvedValue({
        id: "tx_789",
        userId: "user_3",
        amount: 75.0,
        currency: "EUR",
        orderId: "pi_canceled",
      });

      await handleStripeWebhook(mockReq as Request, mockRes as Response);

      expect(mockTransactionUpdateMany).toHaveBeenCalledWith({
        where: {
          orderId: "pi_canceled",
          provider: "stripe",
          status: "pending",
        },
        data: { status: "canceled", description: "Payment canceled" },
      });

      expect(mockAuditLogCreate).toHaveBeenCalledWith({
        data: expect.objectContaining({
          userId: "user_3",
          action: "payment_intent_canceled",
          resourceId: "pi_canceled",
        }),
      });

      expect(mockSocketEmit).toHaveBeenCalledWith("payment-status", {
        orderId: "pi_canceled",
        status: "canceled",
        amount: 75.0,
        currency: "EUR",
      });

      expect(jsonSpy).toHaveBeenCalledWith({ received: true });
    });
  });

  describe("error handling", () => {
    test("returns 400 when signature is missing", async () => {
      mockReq.headers = {};

      await handleStripeWebhook(mockReq as Request, mockRes as Response);

      expect(statusSpy).toHaveBeenCalledWith(400);
      expect(sendSpy).toHaveBeenCalledWith("Missing signature");
    });

    test("returns 400 when webhook verification fails", async () => {
      mockWebhooksConstructEvent.mockImplementation(() => {
        throw new Error("Invalid signature");
      });

      await handleStripeWebhook(mockReq as Request, mockRes as Response);

      expect(statusSpy).toHaveBeenCalledWith(400);
      expect(sendSpy).toHaveBeenCalledWith("Webhook Error");
    });
  });
});

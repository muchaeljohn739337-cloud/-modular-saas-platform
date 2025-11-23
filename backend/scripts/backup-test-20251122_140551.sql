--
-- PostgreSQL database dump
--

\restrict eWhiOmFzNBmNxXed230CoXreH4Ns5que0MCli3sYFu7WX8CbnWDgzHDDw0MY422

-- Dumped from database version 15.15 (Debian 15.15-1.pgdg13+1)
-- Dumped by pg_dump version 15.15 (Debian 15.15-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: AlertMode; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."AlertMode" AS ENUM (
    'IMMEDIATE',
    'BATCHED',
    'MIXED'
);


ALTER TYPE public."AlertMode" OWNER TO postgres;

--
-- Name: AlertSeverity; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."AlertSeverity" AS ENUM (
    'LOW',
    'MEDIUM',
    'HIGH',
    'CRITICAL'
);


ALTER TYPE public."AlertSeverity" OWNER TO postgres;

--
-- Name: ConsultationStatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."ConsultationStatus" AS ENUM (
    'SCHEDULED',
    'ACTIVE',
    'COMPLETED',
    'CANCELLED'
);


ALTER TYPE public."ConsultationStatus" OWNER TO postgres;

--
-- Name: Currency; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."Currency" AS ENUM (
    'USD',
    'ETH',
    'BTC'
);


ALTER TYPE public."Currency" OWNER TO postgres;

--
-- Name: DoctorStatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."DoctorStatus" AS ENUM (
    'PENDING',
    'VERIFIED',
    'SUSPENDED'
);


ALTER TYPE public."DoctorStatus" OWNER TO postgres;

--
-- Name: EthActivityType; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."EthActivityType" AS ENUM (
    'DEPOSIT',
    'WITHDRAWAL'
);


ALTER TYPE public."EthActivityType" OWNER TO postgres;

--
-- Name: OALStatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."OALStatus" AS ENUM (
    'PENDING',
    'APPROVED',
    'REJECTED'
);


ALTER TYPE public."OALStatus" OWNER TO postgres;

--
-- Name: RPAExecutionStatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."RPAExecutionStatus" AS ENUM (
    'RUNNING',
    'SUCCESS',
    'FAILED'
);


ALTER TYPE public."RPAExecutionStatus" OWNER TO postgres;

--
-- Name: ReviewStatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."ReviewStatus" AS ENUM (
    'PENDING',
    'APPROVED',
    'REJECTED',
    'HIDDEN'
);


ALTER TYPE public."ReviewStatus" OWNER TO postgres;

--
-- Name: Role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."Role" AS ENUM (
    'USER',
    'STAFF',
    'ADMIN',
    'SUPERADMIN'
);


ALTER TYPE public."Role" OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: CryptoPayments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CryptoPayments" (
    id text NOT NULL,
    user_id text NOT NULL,
    invoice_id text NOT NULL,
    amount double precision NOT NULL,
    currency text NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    payment_url text,
    order_id text,
    description text,
    paid_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone,
    updated_at timestamp(3) without time zone,
    "paymentProvider" text DEFAULT 'cryptomus'::text
);


ALTER TABLE public."CryptoPayments" OWNER TO postgres;

--
-- Name: RPAExecution; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."RPAExecution" (
    id text NOT NULL,
    "workflowId" text NOT NULL,
    status public."RPAExecutionStatus" DEFAULT 'RUNNING'::public."RPAExecutionStatus" NOT NULL,
    trigger jsonb NOT NULL,
    steps jsonb NOT NULL,
    error text,
    "startedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "completedAt" timestamp(3) without time zone
);


ALTER TABLE public."RPAExecution" OWNER TO postgres;

--
-- Name: RPAWorkflow; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."RPAWorkflow" (
    id text NOT NULL,
    name text NOT NULL,
    description text,
    trigger jsonb NOT NULL,
    actions jsonb NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "createdById" text NOT NULL
);


ALTER TABLE public."RPAWorkflow" OWNER TO postgres;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO postgres;

--
-- Name: activity_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.activity_logs (
    id text NOT NULL,
    "userId" text,
    action text NOT NULL,
    "ipAddress" text NOT NULL,
    "userAgent" text NOT NULL,
    metadata jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.activity_logs OWNER TO postgres;

--
-- Name: admin_login_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin_login_logs (
    id integer NOT NULL,
    email text NOT NULL,
    phone text,
    status text NOT NULL,
    "ipAddress" text,
    "userAgent" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.admin_login_logs OWNER TO postgres;

--
-- Name: admin_login_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.admin_login_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.admin_login_logs_id_seq OWNER TO postgres;

--
-- Name: admin_login_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.admin_login_logs_id_seq OWNED BY public.admin_login_logs.id;


--
-- Name: admin_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin_messages (
    id text NOT NULL,
    "userId" text NOT NULL,
    "fromAdminId" text NOT NULL,
    "fromAdmin" text NOT NULL,
    "toUserId" text,
    subject text,
    message text NOT NULL,
    attachments jsonb,
    priority text DEFAULT 'normal'::text NOT NULL,
    category text,
    "isRead" boolean DEFAULT false NOT NULL,
    "readAt" timestamp(3) without time zone,
    "repliedTo" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.admin_messages OWNER TO postgres;

--
-- Name: admin_notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin_notifications (
    id text NOT NULL,
    type text NOT NULL,
    title text NOT NULL,
    message text NOT NULL,
    "userId" text,
    metadata jsonb,
    read boolean DEFAULT false NOT NULL,
    "readAt" timestamp(3) without time zone,
    "actionUrl" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.admin_notifications OWNER TO postgres;

--
-- Name: admin_portfolios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin_portfolios (
    id text NOT NULL,
    currency public."Currency" NOT NULL,
    balance numeric(65,30) DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.admin_portfolios OWNER TO postgres;

--
-- Name: admin_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin_settings (
    id text NOT NULL,
    "btcAddress" text,
    "ethAddress" text,
    "usdtAddress" text,
    "ltcAddress" text,
    "otherAddresses" text,
    "exchangeRateBtc" numeric(65,30),
    "exchangeRateEth" numeric(65,30),
    "exchangeRateUsdt" numeric(65,30),
    "processingFeePercent" numeric(65,30) DEFAULT 2.5 NOT NULL,
    "minPurchaseAmount" numeric(65,30) DEFAULT 10 NOT NULL,
    "debitCardPriceUSD" numeric(65,30) DEFAULT 1000 NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.admin_settings OWNER TO postgres;

--
-- Name: admin_transfers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin_transfers (
    id text NOT NULL,
    "adminId" text,
    "userId" text,
    currency public."Currency" NOT NULL,
    amount numeric(65,30) NOT NULL,
    note text,
    source text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.admin_transfers OWNER TO postgres;

--
-- Name: admin_user_notes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin_user_notes (
    id text NOT NULL,
    "userId" text NOT NULL,
    "adminId" text NOT NULL,
    "noteType" text NOT NULL,
    title text NOT NULL,
    content text NOT NULL,
    priority text DEFAULT 'normal'::text NOT NULL,
    tags text,
    metadata jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.admin_user_notes OWNER TO postgres;

--
-- Name: admin_wallet_transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin_wallet_transactions (
    id text NOT NULL,
    "adminWalletId" text NOT NULL,
    "userId" text,
    amount numeric(65,30) NOT NULL,
    currency text NOT NULL,
    type text NOT NULL,
    description text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.admin_wallet_transactions OWNER TO postgres;

--
-- Name: admin_wallets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin_wallets (
    id text NOT NULL,
    currency text NOT NULL,
    balance numeric(65,30) DEFAULT 0 NOT NULL,
    "totalIn" numeric(65,30) DEFAULT 0 NOT NULL,
    "totalOut" numeric(65,30) DEFAULT 0 NOT NULL,
    "walletAddress" text,
    "walletProvider" text,
    "walletNotes" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.admin_wallets OWNER TO postgres;

--
-- Name: alert_policies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alert_policies (
    id text NOT NULL,
    "routeGroup" text NOT NULL,
    threshold integer NOT NULL,
    cooldown integer DEFAULT 300000 NOT NULL,
    mode public."AlertMode" DEFAULT 'IMMEDIATE'::public."AlertMode" NOT NULL,
    "batchIntervalMs" integer,
    channels text[],
    severity public."AlertSeverity" DEFAULT 'MEDIUM'::public."AlertSeverity" NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "createdBy" text NOT NULL,
    "updatedBy" text NOT NULL
);


ALTER TABLE public.alert_policies OWNER TO postgres;

--
-- Name: analytics_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.analytics_events (
    id text NOT NULL,
    "userId" text,
    "sessionId" text,
    "eventName" text NOT NULL,
    "eventProperties" jsonb,
    "userProperties" jsonb,
    "deviceInfo" jsonb,
    "timestamp" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "ipAddress" text,
    "userAgent" text,
    referrer text,
    url text,
    platform text,
    "appVersion" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.analytics_events OWNER TO postgres;

--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_logs (
    id text NOT NULL,
    "userId" text,
    action text NOT NULL,
    "resourceType" text NOT NULL,
    "resourceId" text NOT NULL,
    changes jsonb,
    "previousValues" jsonb,
    "newValues" jsonb,
    metadata jsonb,
    "ipAddress" text,
    "userAgent" text,
    "timestamp" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    details jsonb
);


ALTER TABLE public.audit_logs OWNER TO postgres;

--
-- Name: backup_codes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.backup_codes (
    id text NOT NULL,
    "userId" text NOT NULL,
    code text NOT NULL,
    "isUsed" boolean DEFAULT false NOT NULL,
    "usedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.backup_codes OWNER TO postgres;

--
-- Name: chat_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_messages (
    id text NOT NULL,
    "sessionId" text NOT NULL,
    "senderType" text NOT NULL,
    "senderId" text,
    content text NOT NULL,
    metadata jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.chat_messages OWNER TO postgres;

--
-- Name: chat_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_sessions (
    id text NOT NULL,
    "userId" text,
    status text DEFAULT 'open'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "assignedAdminId" text
);


ALTER TABLE public.chat_sessions OWNER TO postgres;

--
-- Name: consultation_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.consultation_messages (
    id text NOT NULL,
    "consultationId" text NOT NULL,
    "senderType" text NOT NULL,
    "senderId" text NOT NULL,
    content text NOT NULL,
    "attachmentUrl" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.consultation_messages OWNER TO postgres;

--
-- Name: consultations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.consultations (
    id text NOT NULL,
    "patientId" text NOT NULL,
    "doctorId" text NOT NULL,
    status public."ConsultationStatus" DEFAULT 'SCHEDULED'::public."ConsultationStatus" NOT NULL,
    "scheduledAt" timestamp(3) without time zone,
    "startedAt" timestamp(3) without time zone,
    "completedAt" timestamp(3) without time zone,
    symptoms text,
    diagnosis text,
    prescription text,
    notes text,
    "videoRoomId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.consultations OWNER TO postgres;

--
-- Name: crypto_orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.crypto_orders (
    id text NOT NULL,
    "userId" text NOT NULL,
    "cryptoType" text NOT NULL,
    "usdAmount" numeric(65,30) NOT NULL,
    "cryptoAmount" numeric(65,30) NOT NULL,
    "exchangeRate" numeric(65,30) NOT NULL,
    "processingFee" numeric(65,30) NOT NULL,
    "totalUsd" numeric(65,30) NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    "adminAddress" text NOT NULL,
    "txHash" text,
    "adminNotes" text,
    "userWalletAddress" text,
    "stripeSessionId" text,
    "completedAt" timestamp(3) without time zone,
    "cancelledAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.crypto_orders OWNER TO postgres;

--
-- Name: crypto_wallets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.crypto_wallets (
    id text NOT NULL,
    "userId" text NOT NULL,
    currency text NOT NULL,
    balance numeric(65,30) DEFAULT 0 NOT NULL,
    address text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "lockedBalance" numeric(65,30) DEFAULT 0 NOT NULL,
    "totalIn" numeric(65,30) DEFAULT 0 NOT NULL,
    "totalOut" numeric(65,30) DEFAULT 0 NOT NULL
);


ALTER TABLE public.crypto_wallets OWNER TO postgres;

--
-- Name: crypto_withdrawals; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.crypto_withdrawals (
    id text NOT NULL,
    "userId" text NOT NULL,
    "cryptoType" text NOT NULL,
    "cryptoAmount" numeric(65,30) NOT NULL,
    "usdEquivalent" numeric(65,30) NOT NULL,
    "withdrawalAddress" text NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    "adminApprovedBy" text,
    "adminNotes" text,
    "txHash" text,
    "networkFee" numeric(65,30),
    "approvedAt" timestamp(3) without time zone,
    "rejectedAt" timestamp(3) without time zone,
    "completedAt" timestamp(3) without time zone,
    "cancelledAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    user_notes text,
    amount numeric(65,30) NOT NULL,
    "approvedBy" text,
    currency text NOT NULL,
    "destinationAddress" text NOT NULL,
    "requestedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "paymentProvider" text DEFAULT 'cryptomus'::text
);


ALTER TABLE public.crypto_withdrawals OWNER TO postgres;

--
-- Name: debit_cards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.debit_cards (
    id text NOT NULL,
    "userId" text NOT NULL,
    "cardNumber" text NOT NULL,
    "cardHolderName" text NOT NULL,
    "expiryMonth" integer NOT NULL,
    "expiryYear" integer NOT NULL,
    cvv text NOT NULL,
    "cardType" text DEFAULT 'virtual'::text NOT NULL,
    status text DEFAULT 'active'::text NOT NULL,
    balance numeric(65,30) DEFAULT 0 NOT NULL,
    "dailyLimit" numeric(65,30) DEFAULT 1000 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.debit_cards OWNER TO postgres;

--
-- Name: doctors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.doctors (
    id text NOT NULL,
    email text NOT NULL,
    "passwordHash" text NOT NULL,
    "firstName" text NOT NULL,
    "lastName" text NOT NULL,
    specialization text NOT NULL,
    "licenseNumber" text NOT NULL,
    "phoneNumber" text,
    status public."DoctorStatus" DEFAULT 'PENDING'::public."DoctorStatus" NOT NULL,
    "verifiedAt" timestamp(3) without time zone,
    "verifiedBy" text,
    "inviteCode" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.doctors OWNER TO postgres;

--
-- Name: email_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.email_logs (
    id text NOT NULL,
    "userId" text,
    "to" text NOT NULL,
    "from" text DEFAULT 'noreply@advancia.com'::text NOT NULL,
    subject text NOT NULL,
    template text NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    provider text DEFAULT 'resend'::text NOT NULL,
    "providerId" text,
    metadata jsonb,
    error text,
    "sentAt" timestamp(3) without time zone,
    "openedAt" timestamp(3) without time zone,
    "clickedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.email_logs OWNER TO postgres;

--
-- Name: eth_activity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.eth_activity (
    id text NOT NULL,
    "userId" text,
    address text NOT NULL,
    "addressNormalized" text NOT NULL,
    type public."EthActivityType" NOT NULL,
    "txHash" text,
    "amountEth" numeric(65,30) NOT NULL,
    status text NOT NULL,
    confirmations integer DEFAULT 0 NOT NULL,
    "blockNumber" integer,
    note text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.eth_activity OWNER TO postgres;

--
-- Name: fee_revenues; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fee_revenues (
    id text NOT NULL,
    "transactionId" text NOT NULL,
    "transactionType" text NOT NULL,
    "userId" text NOT NULL,
    "baseCurrency" text NOT NULL,
    "baseAmount" numeric(65,30) NOT NULL,
    "feePercent" numeric(65,30) NOT NULL,
    "flatFee" numeric(65,30) NOT NULL,
    "totalFee" numeric(65,30) NOT NULL,
    "netAmount" numeric(65,30) NOT NULL,
    "revenueUSD" numeric(65,30) NOT NULL,
    "feeRuleId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.fee_revenues OWNER TO postgres;

--
-- Name: fraud_alerts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fraud_alerts (
    id text NOT NULL,
    "userId" text NOT NULL,
    "alertType" text NOT NULL,
    severity text NOT NULL,
    description text NOT NULL,
    metadata jsonb,
    "ipAddress" text,
    resolved boolean DEFAULT false NOT NULL,
    "resolvedAt" timestamp(3) without time zone,
    "resolvedBy" text,
    "actionTaken" text,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.fraud_alerts OWNER TO postgres;

--
-- Name: health_readings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.health_readings (
    id text NOT NULL,
    "userId" text NOT NULL,
    "heartRate" integer,
    "bloodPressureSys" integer,
    "bloodPressureDia" integer,
    steps integer,
    "sleepHours" numeric(65,30),
    "sleepQuality" text,
    weight numeric(65,30),
    temperature numeric(65,30),
    "oxygenLevel" integer,
    "stressLevel" text,
    mood text,
    "deviceId" text,
    "deviceType" text,
    metadata text,
    notes text,
    "recordedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.health_readings OWNER TO postgres;

--
-- Name: invoice_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invoice_items (
    id text NOT NULL,
    "invoiceId" text NOT NULL,
    description text NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    "unitPrice" numeric(65,30) NOT NULL,
    amount numeric(65,30) NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.invoice_items OWNER TO postgres;

--
-- Name: invoices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invoices (
    id text NOT NULL,
    "invoiceNumber" text NOT NULL,
    "userId" text NOT NULL,
    amount numeric(65,30) NOT NULL,
    currency text DEFAULT 'USD'::text NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    type text DEFAULT 'transaction'::text NOT NULL,
    "billingName" text,
    "billingEmail" text,
    "billingAddress" text,
    "issueDate" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "dueDate" timestamp(3) without time zone NOT NULL,
    "paidDate" timestamp(3) without time zone,
    "transactionId" text,
    "pdfUrl" text,
    "pdfGenerated" boolean DEFAULT false NOT NULL,
    notes text,
    metadata jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.invoices OWNER TO postgres;

--
-- Name: ip_blocks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ip_blocks (
    id text NOT NULL,
    ip text NOT NULL,
    reason text,
    until timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.ip_blocks OWNER TO postgres;

--
-- Name: ip_reputations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ip_reputations (
    id text NOT NULL,
    "ipAddress" text NOT NULL,
    "riskScore" integer DEFAULT 0 NOT NULL,
    "isVPN" boolean DEFAULT false NOT NULL,
    "isProxy" boolean DEFAULT false NOT NULL,
    "isTor" boolean DEFAULT false NOT NULL,
    "isHosting" boolean DEFAULT false NOT NULL,
    country text,
    city text,
    isp text,
    blacklisted boolean DEFAULT false NOT NULL,
    whitelisted boolean DEFAULT false NOT NULL,
    notes text,
    "lastChecked" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "checkCount" integer DEFAULT 1 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.ip_reputations OWNER TO postgres;

--
-- Name: kyc_verifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kyc_verifications (
    id text NOT NULL,
    "userId" text NOT NULL,
    "kycLevel" integer DEFAULT 0 NOT NULL,
    status text DEFAULT 'not_started'::text NOT NULL,
    "firstName" text,
    "lastName" text,
    "dateOfBirth" timestamp(3) without time zone,
    nationality text,
    "idDocumentType" text,
    "idDocumentNumber" text,
    "idDocumentFront" text,
    "idDocumentBack" text,
    "selfieImage" text,
    "addressProof" text,
    "addressLine1" text,
    "addressLine2" text,
    city text,
    state text,
    "postalCode" text,
    country text,
    "phoneNumber" text,
    "verifiedAt" timestamp(3) without time zone,
    "verifiedBy" text,
    "rejectedAt" timestamp(3) without time zone,
    "rejectionReason" text,
    "submittedAt" timestamp(3) without time zone,
    "dailyWithdrawLimit" numeric(65,30) DEFAULT 100 NOT NULL,
    "monthlyWithdrawLimit" numeric(65,30) DEFAULT 1000 NOT NULL,
    "lifetimeLimit" numeric(65,30) DEFAULT 10000 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.kyc_verifications OWNER TO postgres;

--
-- Name: loans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.loans (
    id text NOT NULL,
    "userId" text NOT NULL,
    amount numeric(65,30) NOT NULL,
    "interestRate" numeric(65,30) NOT NULL,
    "termMonths" integer NOT NULL,
    "monthlyPayment" numeric(65,30) NOT NULL,
    "remainingBalance" numeric(65,30) NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    purpose text NOT NULL,
    "startDate" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "dueDate" timestamp(3) without time zone NOT NULL,
    "approvedBy" text,
    "approvedAt" timestamp(3) without time zone,
    "paidOffAt" timestamp(3) without time zone,
    "defaultedAt" timestamp(3) without time zone,
    "cancelledAt" timestamp(3) without time zone,
    "adminNotes" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.loans OWNER TO postgres;

--
-- Name: medbeds_bookings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.medbeds_bookings (
    id text NOT NULL,
    "userId" text NOT NULL,
    "chamberType" text NOT NULL,
    "chamberName" text NOT NULL,
    "sessionDate" timestamp(3) without time zone NOT NULL,
    duration integer NOT NULL,
    cost numeric(10,2) NOT NULL,
    "paymentMethod" text NOT NULL,
    "paymentStatus" text DEFAULT 'pending'::text NOT NULL,
    "transactionId" text,
    "stripeSessionId" text,
    status text DEFAULT 'scheduled'::text NOT NULL,
    effectiveness integer,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.medbeds_bookings OWNER TO postgres;

--
-- Name: notification_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification_logs (
    id text NOT NULL,
    "notificationId" text NOT NULL,
    channel text NOT NULL,
    status text NOT NULL,
    "errorMessage" text,
    "sentAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "deliveredAt" timestamp(3) without time zone,
    metadata jsonb
);


ALTER TABLE public.notification_logs OWNER TO postgres;

--
-- Name: notification_preferences; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification_preferences (
    id text NOT NULL,
    "userId" text NOT NULL,
    "emailEnabled" boolean DEFAULT true NOT NULL,
    "smsEnabled" boolean DEFAULT false NOT NULL,
    "inAppEnabled" boolean DEFAULT true NOT NULL,
    "pushEnabled" boolean DEFAULT true NOT NULL,
    "transactionAlerts" boolean DEFAULT true NOT NULL,
    "securityAlerts" boolean DEFAULT true NOT NULL,
    "systemAlerts" boolean DEFAULT true NOT NULL,
    "rewardAlerts" boolean DEFAULT true NOT NULL,
    "adminAlerts" boolean DEFAULT true NOT NULL,
    "promotionalEmails" boolean DEFAULT false NOT NULL,
    "enableDigest" boolean DEFAULT false NOT NULL,
    "digestFrequency" text DEFAULT 'daily'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.notification_preferences OWNER TO postgres;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id text NOT NULL,
    "userId" text NOT NULL,
    type text NOT NULL,
    priority text DEFAULT 'normal'::text NOT NULL,
    category text NOT NULL,
    title text NOT NULL,
    message text NOT NULL,
    data jsonb,
    "isRead" boolean DEFAULT false NOT NULL,
    "readAt" timestamp(3) without time zone,
    "emailSent" boolean DEFAULT false NOT NULL,
    "emailSentAt" timestamp(3) without time zone,
    "smsSent" boolean DEFAULT false NOT NULL,
    "smsSentAt" timestamp(3) without time zone,
    "pushSent" boolean DEFAULT false NOT NULL,
    "pushSentAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: oal_audit_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.oal_audit_log (
    id text NOT NULL,
    object text NOT NULL,
    action text NOT NULL,
    location text NOT NULL,
    "subjectId" text,
    metadata jsonb,
    status public."OALStatus" DEFAULT 'PENDING'::public."OALStatus" NOT NULL,
    "createdById" text NOT NULL,
    "updatedById" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.oal_audit_log OWNER TO postgres;

--
-- Name: password_reset_requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.password_reset_requests (
    id text NOT NULL,
    "userId" text NOT NULL,
    email text NOT NULL,
    token text NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    used boolean DEFAULT false NOT NULL,
    "usedAt" timestamp(3) without time zone,
    "ipAddress" text,
    "userAgent" text,
    "adminViewed" boolean DEFAULT false NOT NULL,
    "adminViewedBy" text,
    "adminViewedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.password_reset_requests OWNER TO postgres;

--
-- Name: payment_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment_sessions (
    id text NOT NULL,
    "sessionId" text NOT NULL,
    "userId" text NOT NULL,
    amount numeric(65,30) NOT NULL,
    currency text DEFAULT 'USD'::text NOT NULL,
    "paymentMethod" text NOT NULL,
    provider text,
    status text DEFAULT 'pending'::text NOT NULL,
    "redirectUrl" text,
    "callbackUrl" text,
    metadata jsonb,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "completedAt" timestamp(3) without time zone,
    "failedReason" text,
    "transactionId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.payment_sessions OWNER TO postgres;

--
-- Name: policy_audit_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.policy_audit_logs (
    id text NOT NULL,
    "policyId" text NOT NULL,
    action text NOT NULL,
    "changedBy" text NOT NULL,
    "userEmail" text NOT NULL,
    "userRole" text NOT NULL,
    "ipAddress" text,
    "userAgent" text,
    "changesBefore" jsonb,
    "changesAfter" jsonb NOT NULL,
    reason text,
    "timestamp" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "entryHash" text,
    "prevHash" text,
    signature text
);


ALTER TABLE public.policy_audit_logs OWNER TO postgres;

--
-- Name: push_subscriptions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.push_subscriptions (
    id text NOT NULL,
    "userId" text NOT NULL,
    endpoint text NOT NULL,
    p256dh text NOT NULL,
    auth text NOT NULL,
    "deviceInfo" jsonb,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.push_subscriptions OWNER TO postgres;

--
-- Name: rewards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rewards (
    id text NOT NULL,
    "userId" text NOT NULL,
    type text NOT NULL,
    amount numeric(65,30) NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    title text NOT NULL,
    description text NOT NULL,
    metadata text,
    "expiresAt" timestamp(3) without time zone,
    "claimedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.rewards OWNER TO postgres;

--
-- Name: sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sessions (
    id text NOT NULL,
    "userId" text NOT NULL,
    token text NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.sessions OWNER TO postgres;

--
-- Name: support_tickets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.support_tickets (
    id text NOT NULL,
    "userId" text NOT NULL,
    subject text NOT NULL,
    message text NOT NULL,
    category text DEFAULT 'GENERAL'::text NOT NULL,
    status text DEFAULT 'OPEN'::text NOT NULL,
    priority text DEFAULT 'MEDIUM'::text NOT NULL,
    response text,
    "resolvedBy" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "resolvedAt" timestamp(3) without time zone
);


ALTER TABLE public.support_tickets OWNER TO postgres;

--
-- Name: system_alerts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.system_alerts (
    id text NOT NULL,
    "alertType" text NOT NULL,
    severity text NOT NULL,
    title text NOT NULL,
    description text NOT NULL,
    "serviceName" text,
    "isResolved" boolean DEFAULT false NOT NULL,
    "resolvedAt" timestamp(3) without time zone,
    "resolvedBy" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.system_alerts OWNER TO postgres;

--
-- Name: system_config; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.system_config (
    id integer NOT NULL,
    key text NOT NULL,
    value text NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.system_config OWNER TO postgres;

--
-- Name: system_config_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.system_config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.system_config_id_seq OWNER TO postgres;

--
-- Name: system_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.system_config_id_seq OWNED BY public.system_config.id;


--
-- Name: system_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.system_status (
    id text NOT NULL,
    "serviceName" text NOT NULL,
    status text NOT NULL,
    "responseTime" integer,
    uptime numeric(65,30),
    "lastChecked" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "statusMessage" text,
    "alertLevel" text DEFAULT 'none'::text NOT NULL,
    metadata text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.system_status OWNER TO postgres;

--
-- Name: token_transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.token_transactions (
    id text NOT NULL,
    "walletId" text NOT NULL,
    amount numeric(65,30) NOT NULL,
    type text NOT NULL,
    status text DEFAULT 'completed'::text NOT NULL,
    description text,
    "toAddress" text,
    "fromAddress" text,
    "txHash" text,
    metadata text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.token_transactions OWNER TO postgres;

--
-- Name: token_wallets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.token_wallets (
    id text NOT NULL,
    "userId" text NOT NULL,
    balance numeric(65,30) DEFAULT 0 NOT NULL,
    "tokenType" text DEFAULT 'ADVANCIA'::text NOT NULL,
    "lockedBalance" numeric(65,30) DEFAULT 0 NOT NULL,
    "lifetimeEarned" numeric(65,30) DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.token_wallets OWNER TO postgres;

--
-- Name: transaction_fees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transaction_fees (
    id text NOT NULL,
    "feeType" text NOT NULL,
    currency text,
    "feePercent" numeric(65,30) DEFAULT 0 NOT NULL,
    "flatFee" numeric(65,30) DEFAULT 0 NOT NULL,
    "minFee" numeric(65,30) DEFAULT 0 NOT NULL,
    "maxFee" numeric(65,30),
    active boolean DEFAULT true NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    description text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "createdBy" text
);


ALTER TABLE public.transaction_fees OWNER TO postgres;

--
-- Name: transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transactions (
    id text NOT NULL,
    "userId" text NOT NULL,
    amount double precision NOT NULL,
    type text NOT NULL,
    description text,
    category text,
    status text DEFAULT 'completed'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    currency text DEFAULT 'USD'::text NOT NULL,
    "orderId" text,
    provider text
);


ALTER TABLE public.transactions OWNER TO postgres;

--
-- Name: trustpilot_reviews; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.trustpilot_reviews (
    id text NOT NULL,
    "reviewId" text NOT NULL,
    "userId" text,
    "userName" text NOT NULL,
    "userEmail" text,
    rating integer NOT NULL,
    title text NOT NULL,
    content text NOT NULL,
    date timestamp(3) without time zone NOT NULL,
    verified boolean DEFAULT false NOT NULL,
    helpful integer DEFAULT 0 NOT NULL,
    "notHelpful" integer DEFAULT 0 NOT NULL,
    response text,
    "responseDate" timestamp(3) without time zone,
    tags text[] DEFAULT ARRAY[]::text[],
    source text DEFAULT 'trustpilot'::text NOT NULL,
    status public."ReviewStatus" DEFAULT 'PENDING'::public."ReviewStatus" NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.trustpilot_reviews OWNER TO postgres;

--
-- Name: two_factor_auth; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.two_factor_auth (
    id text NOT NULL,
    "userId" text NOT NULL,
    secret text NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    "backupCodes" text[],
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.two_factor_auth OWNER TO postgres;

--
-- Name: user_activities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_activities (
    id text NOT NULL,
    "userId" text NOT NULL,
    email text NOT NULL,
    action text NOT NULL,
    details jsonb,
    "ipAddress" text,
    "userAgent" text,
    location text,
    successful boolean DEFAULT true NOT NULL,
    metadata jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.user_activities OWNER TO postgres;

--
-- Name: user_profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_profiles (
    id text NOT NULL,
    "userId" text NOT NULL,
    bio text,
    "createdAt" timestamp(3) without time zone NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.user_profiles OWNER TO postgres;

--
-- Name: user_tiers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_tiers (
    id text NOT NULL,
    "userId" text NOT NULL,
    "currentTier" text DEFAULT 'bronze'::text NOT NULL,
    points integer DEFAULT 0 NOT NULL,
    "lifetimePoints" integer DEFAULT 0 NOT NULL,
    "lifetimeRewards" numeric(65,30) DEFAULT 0 NOT NULL,
    streak integer DEFAULT 0 NOT NULL,
    "longestStreak" integer DEFAULT 0 NOT NULL,
    "lastActiveDate" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    achievements text,
    badges text,
    "referralCode" text,
    "referredBy" text,
    "totalReferrals" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.user_tiers OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id text NOT NULL,
    email text NOT NULL,
    username text NOT NULL,
    "passwordHash" text NOT NULL,
    "firstName" text,
    "lastName" text,
    role public."Role" DEFAULT 'USER'::public."Role" NOT NULL,
    "usdBalance" numeric(65,30) DEFAULT 0 NOT NULL,
    active boolean DEFAULT true NOT NULL,
    "emailVerified" boolean DEFAULT false NOT NULL,
    "emailVerifiedAt" timestamp(3) without time zone,
    "lastLogin" timestamp(3) without time zone,
    "termsAccepted" boolean DEFAULT false NOT NULL,
    "termsAcceptedAt" timestamp(3) without time zone,
    "totpSecret" text,
    "totpEnabled" boolean DEFAULT false NOT NULL,
    "totpVerified" boolean DEFAULT false NOT NULL,
    "backupCodes" text,
    "ethWalletAddress" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "btcBalance" numeric(65,30) DEFAULT 0 NOT NULL,
    "ethBalance" numeric(65,30) DEFAULT 0 NOT NULL,
    "usdtBalance" numeric(65,30) DEFAULT 0 NOT NULL,
    address text,
    approved boolean DEFAULT false NOT NULL,
    "approvedAt" timestamp(3) without time zone,
    "approvedBy" text,
    city text,
    country text,
    "phoneNumber" text,
    "postalCode" text,
    "profileImage" text,
    "rejectedAt" timestamp(3) without time zone,
    "rejectionReason" text,
    "emailSignupToken" text,
    "emailSignupTokenExpiry" timestamp(3) without time zone,
    "firstLoginCompleted" boolean DEFAULT false NOT NULL,
    "signupMethod" text DEFAULT 'password'::text NOT NULL,
    "stripeCustomerId" text,
    "gpt5Enabled" boolean DEFAULT false NOT NULL,
    "whitelistedIPs" text[]
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: whitelisted_addresses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.whitelisted_addresses (
    id text NOT NULL,
    "userId" text NOT NULL,
    address text NOT NULL,
    currency text NOT NULL,
    label text,
    verified boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.whitelisted_addresses OWNER TO postgres;

--
-- Name: withdrawal_queue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.withdrawal_queue (
    id text NOT NULL,
    "withdrawalId" text NOT NULL,
    "userId" text NOT NULL,
    "cryptoType" text NOT NULL,
    amount numeric(65,30) NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    status text DEFAULT 'queued'::text NOT NULL,
    "attemptCount" integer DEFAULT 0 NOT NULL,
    "lastAttemptAt" timestamp(3) without time zone,
    "errorMessage" text,
    "assignedTo" text,
    "estimatedTime" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.withdrawal_queue OWNER TO postgres;

--
-- Name: admin_login_logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_login_logs ALTER COLUMN id SET DEFAULT nextval('public.admin_login_logs_id_seq'::regclass);


--
-- Name: system_config id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system_config ALTER COLUMN id SET DEFAULT nextval('public.system_config_id_seq'::regclass);


--
-- Data for Name: CryptoPayments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CryptoPayments" (id, user_id, invoice_id, amount, currency, status, payment_url, order_id, description, paid_at, created_at, updated_at, "paymentProvider") FROM stdin;
\.


--
-- Data for Name: RPAExecution; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."RPAExecution" (id, "workflowId", status, trigger, steps, error, "startedAt", "completedAt") FROM stdin;
\.


--
-- Data for Name: RPAWorkflow; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."RPAWorkflow" (id, name, description, trigger, actions, enabled, "createdAt", "updatedAt", "createdById") FROM stdin;
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
f833efca-7228-48b9-a7c8-527ec1d35d97	49cac26869a3773aa16ce837edef9e12211abe6df9333d2ce63caff95318ed0c	2025-11-22 04:49:07.114632+00	20251109112848_init	\N	\N	2025-11-22 04:49:06.057658+00	1
ce1f9116-fc9e-4f22-97bb-80e02a62a251	2a3b8c898245042c7d19f67a79c801b989b47c399a75b0e664ba3025e219fd9e	2025-11-22 04:49:07.181525+00	20251109121700_test_init	\N	\N	2025-11-22 04:49:07.133242+00	1
f4c06f8c-f2e6-4702-ad85-74f8bfcd0c2a	754976be5b8ef281659fa744e5641887f2ab5d8ef33286900dc5153ed971c08a	2025-11-22 04:49:07.676703+00	20251111015408_add_analytics_events	\N	\N	2025-11-22 04:49:07.225219+00	1
a872dc85-1a9c-4768-91bd-a302ba028757	054e5c59ff47454062a7cb83d7f323ac393ec07013ae33dbfd8e521616e601f0	2025-11-22 04:49:08.162804+00	20251118084553_add_admin_wallet_addresses	\N	\N	2025-11-22 04:49:07.712311+00	1
8d9e56ac-41b0-4188-a1af-4289330de7f1	36526476ea07fe559db5c2ded1e0db30ed44d24e49e04931157a5db20d3c36b7	2025-11-22 04:49:08.235962+00	20251118090000_add_custodial_wallet_keys	\N	\N	2025-11-22 04:49:08.186938+00	1
150dcbdf-b6d9-4005-9da1-cbe33daecf2e	938d0640d543f0a69aed65b205f927d03a85d0d4eedd5a5954cbd15d86e0b30b	2025-11-22 04:49:08.327297+00	20251118092211_add_withdrawal_wallet_fields	\N	\N	2025-11-22 04:49:08.273558+00	1
f0801eb7-f1e5-4aed-beb1-17ef27c7292b	e4ab3a857ce6a58abe8046502be0663f19dfbd1fc1fb1f662c47062eb9430c3a	2025-11-22 04:49:08.411725+00	20251119062453_add_trustpilot_review_model	\N	\N	2025-11-22 04:49:08.362564+00	1
633ebd9d-2b15-4c09-bcb3-cf8f515f76cc	797c83722b40e7e2de74dd30b09f040bfc26aa1919bf79e955ee55a10c1e65da	2025-11-22 11:20:26.689065+00	20251122112026_add_payment_provider	\N	\N	2025-11-22 11:20:26.635374+00	1
0dee74fb-c51f-48da-bad7-1aa9838bc8e2	360f4683f7a930e8ceb70269d1d863cb5196508e3d4fe0ea107e5cb3a64cda63	2025-11-22 12:14:01.458567+00	20251122121401_add_payment_provider_to_withdrawals	\N	\N	2025-11-22 12:14:01.411781+00	1
de361062-2dfc-4983-93e7-9c8b8f8a7411	10ae4e5b5e1ae0cd6f6ff5c33a2b58592160141ee3a0892d0c17281591c1ea18	2025-11-22 13:10:18.877718+00	20251122131018_add_ip_address_whitelist	\N	\N	2025-11-22 13:10:18.806552+00	1
18d948d9-0a99-4f3c-97fe-36b30f15cc03	4fd28ee7b6e3dc664e3dd5d9079047c2fc696df7607934b01221d09f946a424a	2025-11-22 14:18:15.836312+00	20251122135805_add_performance_indexes	\N	\N	2025-11-22 14:18:15.652462+00	1
\.


--
-- Data for Name: activity_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activity_logs (id, "userId", action, "ipAddress", "userAgent", metadata, "createdAt") FROM stdin;
\.


--
-- Data for Name: admin_login_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin_login_logs (id, email, phone, status, "ipAddress", "userAgent", "createdAt") FROM stdin;
\.


--
-- Data for Name: admin_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin_messages (id, "userId", "fromAdminId", "fromAdmin", "toUserId", subject, message, attachments, priority, category, "isRead", "readAt", "repliedTo", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: admin_notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin_notifications (id, type, title, message, "userId", metadata, read, "readAt", "actionUrl", "createdAt") FROM stdin;
\.


--
-- Data for Name: admin_portfolios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin_portfolios (id, currency, balance, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: admin_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin_settings (id, "btcAddress", "ethAddress", "usdtAddress", "ltcAddress", "otherAddresses", "exchangeRateBtc", "exchangeRateEth", "exchangeRateUsdt", "processingFeePercent", "minPurchaseAmount", "debitCardPriceUSD", "updatedAt", "createdAt") FROM stdin;
\.


--
-- Data for Name: admin_transfers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin_transfers (id, "adminId", "userId", currency, amount, note, source, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: admin_user_notes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin_user_notes (id, "userId", "adminId", "noteType", title, content, priority, tags, metadata, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: admin_wallet_transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin_wallet_transactions (id, "adminWalletId", "userId", amount, currency, type, description, "createdAt") FROM stdin;
\.


--
-- Data for Name: admin_wallets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin_wallets (id, currency, balance, "totalIn", "totalOut", "walletAddress", "walletProvider", "walletNotes", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: alert_policies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alert_policies (id, "routeGroup", threshold, cooldown, mode, "batchIntervalMs", channels, severity, enabled, "createdAt", "updatedAt", "createdBy", "updatedBy") FROM stdin;
\.


--
-- Data for Name: analytics_events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.analytics_events (id, "userId", "sessionId", "eventName", "eventProperties", "userProperties", "deviceInfo", "timestamp", "ipAddress", "userAgent", referrer, url, platform, "appVersion", "createdAt") FROM stdin;
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit_logs (id, "userId", action, "resourceType", "resourceId", changes, "previousValues", "newValues", metadata, "ipAddress", "userAgent", "timestamp", "createdAt", details) FROM stdin;
\.


--
-- Data for Name: backup_codes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.backup_codes (id, "userId", code, "isUsed", "usedAt", "createdAt") FROM stdin;
\.


--
-- Data for Name: chat_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_messages (id, "sessionId", "senderType", "senderId", content, metadata, "createdAt") FROM stdin;
\.


--
-- Data for Name: chat_sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_sessions (id, "userId", status, "createdAt", "updatedAt", "assignedAdminId") FROM stdin;
\.


--
-- Data for Name: consultation_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.consultation_messages (id, "consultationId", "senderType", "senderId", content, "attachmentUrl", "createdAt") FROM stdin;
\.


--
-- Data for Name: consultations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.consultations (id, "patientId", "doctorId", status, "scheduledAt", "startedAt", "completedAt", symptoms, diagnosis, prescription, notes, "videoRoomId", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: crypto_orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.crypto_orders (id, "userId", "cryptoType", "usdAmount", "cryptoAmount", "exchangeRate", "processingFee", "totalUsd", status, "adminAddress", "txHash", "adminNotes", "userWalletAddress", "stripeSessionId", "completedAt", "cancelledAt", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: crypto_wallets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.crypto_wallets (id, "userId", currency, balance, address, "createdAt", "updatedAt", "lockedBalance", "totalIn", "totalOut") FROM stdin;
\.


--
-- Data for Name: crypto_withdrawals; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.crypto_withdrawals (id, "userId", "cryptoType", "cryptoAmount", "usdEquivalent", "withdrawalAddress", status, "adminApprovedBy", "adminNotes", "txHash", "networkFee", "approvedAt", "rejectedAt", "completedAt", "cancelledAt", "createdAt", "updatedAt", user_notes, amount, "approvedBy", currency, "destinationAddress", "requestedAt", "paymentProvider") FROM stdin;
\.


--
-- Data for Name: debit_cards; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.debit_cards (id, "userId", "cardNumber", "cardHolderName", "expiryMonth", "expiryYear", cvv, "cardType", status, balance, "dailyLimit", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: doctors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.doctors (id, email, "passwordHash", "firstName", "lastName", specialization, "licenseNumber", "phoneNumber", status, "verifiedAt", "verifiedBy", "inviteCode", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: email_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.email_logs (id, "userId", "to", "from", subject, template, status, provider, "providerId", metadata, error, "sentAt", "openedAt", "clickedAt", "createdAt") FROM stdin;
\.


--
-- Data for Name: eth_activity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.eth_activity (id, "userId", address, "addressNormalized", type, "txHash", "amountEth", status, confirmations, "blockNumber", note, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: fee_revenues; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fee_revenues (id, "transactionId", "transactionType", "userId", "baseCurrency", "baseAmount", "feePercent", "flatFee", "totalFee", "netAmount", "revenueUSD", "feeRuleId", "createdAt") FROM stdin;
\.


--
-- Data for Name: fraud_alerts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fraud_alerts (id, "userId", "alertType", severity, description, metadata, "ipAddress", resolved, "resolvedAt", "resolvedBy", "actionTaken", notes, "createdAt") FROM stdin;
\.


--
-- Data for Name: health_readings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.health_readings (id, "userId", "heartRate", "bloodPressureSys", "bloodPressureDia", steps, "sleepHours", "sleepQuality", weight, temperature, "oxygenLevel", "stressLevel", mood, "deviceId", "deviceType", metadata, notes, "recordedAt", "createdAt") FROM stdin;
\.


--
-- Data for Name: invoice_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invoice_items (id, "invoiceId", description, quantity, "unitPrice", amount, "createdAt") FROM stdin;
\.


--
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invoices (id, "invoiceNumber", "userId", amount, currency, status, type, "billingName", "billingEmail", "billingAddress", "issueDate", "dueDate", "paidDate", "transactionId", "pdfUrl", "pdfGenerated", notes, metadata, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ip_blocks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ip_blocks (id, ip, reason, until, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ip_reputations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ip_reputations (id, "ipAddress", "riskScore", "isVPN", "isProxy", "isTor", "isHosting", country, city, isp, blacklisted, whitelisted, notes, "lastChecked", "checkCount", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: kyc_verifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kyc_verifications (id, "userId", "kycLevel", status, "firstName", "lastName", "dateOfBirth", nationality, "idDocumentType", "idDocumentNumber", "idDocumentFront", "idDocumentBack", "selfieImage", "addressProof", "addressLine1", "addressLine2", city, state, "postalCode", country, "phoneNumber", "verifiedAt", "verifiedBy", "rejectedAt", "rejectionReason", "submittedAt", "dailyWithdrawLimit", "monthlyWithdrawLimit", "lifetimeLimit", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: loans; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.loans (id, "userId", amount, "interestRate", "termMonths", "monthlyPayment", "remainingBalance", status, purpose, "startDate", "dueDate", "approvedBy", "approvedAt", "paidOffAt", "defaultedAt", "cancelledAt", "adminNotes", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: medbeds_bookings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.medbeds_bookings (id, "userId", "chamberType", "chamberName", "sessionDate", duration, cost, "paymentMethod", "paymentStatus", "transactionId", "stripeSessionId", status, effectiveness, notes, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: notification_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notification_logs (id, "notificationId", channel, status, "errorMessage", "sentAt", "deliveredAt", metadata) FROM stdin;
\.


--
-- Data for Name: notification_preferences; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notification_preferences (id, "userId", "emailEnabled", "smsEnabled", "inAppEnabled", "pushEnabled", "transactionAlerts", "securityAlerts", "systemAlerts", "rewardAlerts", "adminAlerts", "promotionalEmails", "enableDigest", "digestFrequency", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (id, "userId", type, priority, category, title, message, data, "isRead", "readAt", "emailSent", "emailSentAt", "smsSent", "smsSentAt", "pushSent", "pushSentAt", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: oal_audit_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.oal_audit_log (id, object, action, location, "subjectId", metadata, status, "createdById", "updatedById", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: password_reset_requests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.password_reset_requests (id, "userId", email, token, "expiresAt", used, "usedAt", "ipAddress", "userAgent", "adminViewed", "adminViewedBy", "adminViewedAt", "createdAt") FROM stdin;
\.


--
-- Data for Name: payment_sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payment_sessions (id, "sessionId", "userId", amount, currency, "paymentMethod", provider, status, "redirectUrl", "callbackUrl", metadata, "expiresAt", "completedAt", "failedReason", "transactionId", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: policy_audit_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.policy_audit_logs (id, "policyId", action, "changedBy", "userEmail", "userRole", "ipAddress", "userAgent", "changesBefore", "changesAfter", reason, "timestamp", "entryHash", "prevHash", signature) FROM stdin;
\.


--
-- Data for Name: push_subscriptions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.push_subscriptions (id, "userId", endpoint, p256dh, auth, "deviceInfo", "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: rewards; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rewards (id, "userId", type, amount, status, title, description, metadata, "expiresAt", "claimedAt", "createdAt") FROM stdin;
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sessions (id, "userId", token, "expiresAt", "createdAt") FROM stdin;
\.


--
-- Data for Name: support_tickets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.support_tickets (id, "userId", subject, message, category, status, priority, response, "resolvedBy", "createdAt", "updatedAt", "resolvedAt") FROM stdin;
\.


--
-- Data for Name: system_alerts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.system_alerts (id, "alertType", severity, title, description, "serviceName", "isResolved", "resolvedAt", "resolvedBy", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: system_config; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.system_config (id, key, value, "updatedAt", "createdAt") FROM stdin;
\.


--
-- Data for Name: system_status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.system_status (id, "serviceName", status, "responseTime", uptime, "lastChecked", "statusMessage", "alertLevel", metadata, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: token_transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.token_transactions (id, "walletId", amount, type, status, description, "toAddress", "fromAddress", "txHash", metadata, "createdAt") FROM stdin;
\.


--
-- Data for Name: token_wallets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.token_wallets (id, "userId", balance, "tokenType", "lockedBalance", "lifetimeEarned", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: transaction_fees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transaction_fees (id, "feeType", currency, "feePercent", "flatFee", "minFee", "maxFee", active, priority, description, "createdAt", "updatedAt", "createdBy") FROM stdin;
\.


--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transactions (id, "userId", amount, type, description, category, status, "createdAt", "updatedAt", currency, "orderId", provider) FROM stdin;
\.


--
-- Data for Name: trustpilot_reviews; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.trustpilot_reviews (id, "reviewId", "userId", "userName", "userEmail", rating, title, content, date, verified, helpful, "notHelpful", response, "responseDate", tags, source, status, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: two_factor_auth; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.two_factor_auth (id, "userId", secret, enabled, "backupCodes", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: user_activities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_activities (id, "userId", email, action, details, "ipAddress", "userAgent", location, successful, metadata, "createdAt") FROM stdin;
\.


--
-- Data for Name: user_profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_profiles (id, "userId", bio, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: user_tiers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_tiers (id, "userId", "currentTier", points, "lifetimePoints", "lifetimeRewards", streak, "longestStreak", "lastActiveDate", achievements, badges, "referralCode", "referredBy", "totalReferrals", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, username, "passwordHash", "firstName", "lastName", role, "usdBalance", active, "emailVerified", "emailVerifiedAt", "lastLogin", "termsAccepted", "termsAcceptedAt", "totpSecret", "totpEnabled", "totpVerified", "backupCodes", "ethWalletAddress", "createdAt", "updatedAt", "btcBalance", "ethBalance", "usdtBalance", address, approved, "approvedAt", "approvedBy", city, country, "phoneNumber", "postalCode", "profileImage", "rejectedAt", "rejectionReason", "emailSignupToken", "emailSignupTokenExpiry", "firstLoginCompleted", "signupMethod", "stripeCustomerId", "gpt5Enabled", "whitelistedIPs") FROM stdin;
\.


--
-- Data for Name: whitelisted_addresses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.whitelisted_addresses (id, "userId", address, currency, label, verified, "createdAt") FROM stdin;
\.


--
-- Data for Name: withdrawal_queue; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.withdrawal_queue (id, "withdrawalId", "userId", "cryptoType", amount, priority, status, "attemptCount", "lastAttemptAt", "errorMessage", "assignedTo", "estimatedTime", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Name: admin_login_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admin_login_logs_id_seq', 1, false);


--
-- Name: system_config_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.system_config_id_seq', 1, false);


--
-- Name: CryptoPayments CryptoPayments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CryptoPayments"
    ADD CONSTRAINT "CryptoPayments_pkey" PRIMARY KEY (id);


--
-- Name: RPAExecution RPAExecution_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."RPAExecution"
    ADD CONSTRAINT "RPAExecution_pkey" PRIMARY KEY (id);


--
-- Name: RPAWorkflow RPAWorkflow_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."RPAWorkflow"
    ADD CONSTRAINT "RPAWorkflow_pkey" PRIMARY KEY (id);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: activity_logs activity_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_logs
    ADD CONSTRAINT activity_logs_pkey PRIMARY KEY (id);


--
-- Name: admin_login_logs admin_login_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_login_logs
    ADD CONSTRAINT admin_login_logs_pkey PRIMARY KEY (id);


--
-- Name: admin_messages admin_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_messages
    ADD CONSTRAINT admin_messages_pkey PRIMARY KEY (id);


--
-- Name: admin_notifications admin_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_notifications
    ADD CONSTRAINT admin_notifications_pkey PRIMARY KEY (id);


--
-- Name: admin_portfolios admin_portfolios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_portfolios
    ADD CONSTRAINT admin_portfolios_pkey PRIMARY KEY (id);


--
-- Name: admin_settings admin_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_settings
    ADD CONSTRAINT admin_settings_pkey PRIMARY KEY (id);


--
-- Name: admin_transfers admin_transfers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_transfers
    ADD CONSTRAINT admin_transfers_pkey PRIMARY KEY (id);


--
-- Name: admin_user_notes admin_user_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_user_notes
    ADD CONSTRAINT admin_user_notes_pkey PRIMARY KEY (id);


--
-- Name: admin_wallet_transactions admin_wallet_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_wallet_transactions
    ADD CONSTRAINT admin_wallet_transactions_pkey PRIMARY KEY (id);


--
-- Name: admin_wallets admin_wallets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_wallets
    ADD CONSTRAINT admin_wallets_pkey PRIMARY KEY (id);


--
-- Name: alert_policies alert_policies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alert_policies
    ADD CONSTRAINT alert_policies_pkey PRIMARY KEY (id);


--
-- Name: analytics_events analytics_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.analytics_events
    ADD CONSTRAINT analytics_events_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: backup_codes backup_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.backup_codes
    ADD CONSTRAINT backup_codes_pkey PRIMARY KEY (id);


--
-- Name: chat_messages chat_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_pkey PRIMARY KEY (id);


--
-- Name: chat_sessions chat_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_sessions
    ADD CONSTRAINT chat_sessions_pkey PRIMARY KEY (id);


--
-- Name: consultation_messages consultation_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.consultation_messages
    ADD CONSTRAINT consultation_messages_pkey PRIMARY KEY (id);


--
-- Name: consultations consultations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.consultations
    ADD CONSTRAINT consultations_pkey PRIMARY KEY (id);


--
-- Name: crypto_orders crypto_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.crypto_orders
    ADD CONSTRAINT crypto_orders_pkey PRIMARY KEY (id);


--
-- Name: crypto_wallets crypto_wallets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.crypto_wallets
    ADD CONSTRAINT crypto_wallets_pkey PRIMARY KEY (id);


--
-- Name: crypto_withdrawals crypto_withdrawals_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.crypto_withdrawals
    ADD CONSTRAINT crypto_withdrawals_pkey PRIMARY KEY (id);


--
-- Name: debit_cards debit_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.debit_cards
    ADD CONSTRAINT debit_cards_pkey PRIMARY KEY (id);


--
-- Name: doctors doctors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctors
    ADD CONSTRAINT doctors_pkey PRIMARY KEY (id);


--
-- Name: email_logs email_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_logs
    ADD CONSTRAINT email_logs_pkey PRIMARY KEY (id);


--
-- Name: eth_activity eth_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.eth_activity
    ADD CONSTRAINT eth_activity_pkey PRIMARY KEY (id);


--
-- Name: fee_revenues fee_revenues_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fee_revenues
    ADD CONSTRAINT fee_revenues_pkey PRIMARY KEY (id);


--
-- Name: fraud_alerts fraud_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fraud_alerts
    ADD CONSTRAINT fraud_alerts_pkey PRIMARY KEY (id);


--
-- Name: health_readings health_readings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.health_readings
    ADD CONSTRAINT health_readings_pkey PRIMARY KEY (id);


--
-- Name: invoice_items invoice_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: ip_blocks ip_blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ip_blocks
    ADD CONSTRAINT ip_blocks_pkey PRIMARY KEY (id);


--
-- Name: ip_reputations ip_reputations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ip_reputations
    ADD CONSTRAINT ip_reputations_pkey PRIMARY KEY (id);


--
-- Name: kyc_verifications kyc_verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kyc_verifications
    ADD CONSTRAINT kyc_verifications_pkey PRIMARY KEY (id);


--
-- Name: loans loans_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loans
    ADD CONSTRAINT loans_pkey PRIMARY KEY (id);


--
-- Name: medbeds_bookings medbeds_bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medbeds_bookings
    ADD CONSTRAINT medbeds_bookings_pkey PRIMARY KEY (id);


--
-- Name: notification_logs notification_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_logs
    ADD CONSTRAINT notification_logs_pkey PRIMARY KEY (id);


--
-- Name: notification_preferences notification_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_preferences
    ADD CONSTRAINT notification_preferences_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: oal_audit_log oal_audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oal_audit_log
    ADD CONSTRAINT oal_audit_log_pkey PRIMARY KEY (id);


--
-- Name: password_reset_requests password_reset_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_requests
    ADD CONSTRAINT password_reset_requests_pkey PRIMARY KEY (id);


--
-- Name: payment_sessions payment_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_sessions
    ADD CONSTRAINT payment_sessions_pkey PRIMARY KEY (id);


--
-- Name: policy_audit_logs policy_audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.policy_audit_logs
    ADD CONSTRAINT policy_audit_logs_pkey PRIMARY KEY (id);


--
-- Name: push_subscriptions push_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.push_subscriptions
    ADD CONSTRAINT push_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: rewards rewards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rewards
    ADD CONSTRAINT rewards_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: support_tickets support_tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.support_tickets
    ADD CONSTRAINT support_tickets_pkey PRIMARY KEY (id);


--
-- Name: system_alerts system_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system_alerts
    ADD CONSTRAINT system_alerts_pkey PRIMARY KEY (id);


--
-- Name: system_config system_config_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system_config
    ADD CONSTRAINT system_config_pkey PRIMARY KEY (id);


--
-- Name: system_status system_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system_status
    ADD CONSTRAINT system_status_pkey PRIMARY KEY (id);


--
-- Name: token_transactions token_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.token_transactions
    ADD CONSTRAINT token_transactions_pkey PRIMARY KEY (id);


--
-- Name: token_wallets token_wallets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.token_wallets
    ADD CONSTRAINT token_wallets_pkey PRIMARY KEY (id);


--
-- Name: transaction_fees transaction_fees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction_fees
    ADD CONSTRAINT transaction_fees_pkey PRIMARY KEY (id);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: trustpilot_reviews trustpilot_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trustpilot_reviews
    ADD CONSTRAINT trustpilot_reviews_pkey PRIMARY KEY (id);


--
-- Name: two_factor_auth two_factor_auth_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.two_factor_auth
    ADD CONSTRAINT two_factor_auth_pkey PRIMARY KEY (id);


--
-- Name: user_activities user_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_activities
    ADD CONSTRAINT user_activities_pkey PRIMARY KEY (id);


--
-- Name: user_profiles user_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_pkey PRIMARY KEY (id);


--
-- Name: user_tiers user_tiers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_tiers
    ADD CONSTRAINT user_tiers_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: whitelisted_addresses whitelisted_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.whitelisted_addresses
    ADD CONSTRAINT whitelisted_addresses_pkey PRIMARY KEY (id);


--
-- Name: withdrawal_queue withdrawal_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.withdrawal_queue
    ADD CONSTRAINT withdrawal_queue_pkey PRIMARY KEY (id);


--
-- Name: CryptoPayments_paymentProvider_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CryptoPayments_paymentProvider_idx" ON public."CryptoPayments" USING btree ("paymentProvider");


--
-- Name: CryptoPayments_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CryptoPayments_status_idx" ON public."CryptoPayments" USING btree (status);


--
-- Name: CryptoPayments_user_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CryptoPayments_user_id_idx" ON public."CryptoPayments" USING btree (user_id);


--
-- Name: RPAExecution_startedAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "RPAExecution_startedAt_idx" ON public."RPAExecution" USING btree ("startedAt");


--
-- Name: RPAExecution_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "RPAExecution_status_idx" ON public."RPAExecution" USING btree (status);


--
-- Name: RPAExecution_workflowId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "RPAExecution_workflowId_idx" ON public."RPAExecution" USING btree ("workflowId");


--
-- Name: RPAWorkflow_createdById_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "RPAWorkflow_createdById_idx" ON public."RPAWorkflow" USING btree ("createdById");


--
-- Name: RPAWorkflow_enabled_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "RPAWorkflow_enabled_idx" ON public."RPAWorkflow" USING btree (enabled);


--
-- Name: admin_login_logs_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "admin_login_logs_createdAt_idx" ON public.admin_login_logs USING btree ("createdAt");


--
-- Name: admin_login_logs_email_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX admin_login_logs_email_idx ON public.admin_login_logs USING btree (email);


--
-- Name: admin_login_logs_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX admin_login_logs_status_idx ON public.admin_login_logs USING btree (status);


--
-- Name: admin_messages_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "admin_messages_createdAt_idx" ON public.admin_messages USING btree ("createdAt");


--
-- Name: admin_messages_fromAdminId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "admin_messages_fromAdminId_idx" ON public.admin_messages USING btree ("fromAdminId");


--
-- Name: admin_messages_isRead_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "admin_messages_isRead_idx" ON public.admin_messages USING btree ("isRead");


--
-- Name: admin_messages_repliedTo_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "admin_messages_repliedTo_idx" ON public.admin_messages USING btree ("repliedTo");


--
-- Name: admin_messages_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "admin_messages_userId_idx" ON public.admin_messages USING btree ("userId");


--
-- Name: admin_notifications_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "admin_notifications_createdAt_idx" ON public.admin_notifications USING btree ("createdAt");


--
-- Name: admin_notifications_read_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX admin_notifications_read_idx ON public.admin_notifications USING btree (read);


--
-- Name: admin_notifications_type_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX admin_notifications_type_idx ON public.admin_notifications USING btree (type);


--
-- Name: admin_portfolios_currency_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX admin_portfolios_currency_key ON public.admin_portfolios USING btree (currency);


--
-- Name: admin_transfers_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "admin_transfers_createdAt_idx" ON public.admin_transfers USING btree ("createdAt");


--
-- Name: admin_transfers_currency_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX admin_transfers_currency_idx ON public.admin_transfers USING btree (currency);


--
-- Name: admin_transfers_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "admin_transfers_userId_idx" ON public.admin_transfers USING btree ("userId");


--
-- Name: admin_user_notes_adminId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "admin_user_notes_adminId_idx" ON public.admin_user_notes USING btree ("adminId");


--
-- Name: admin_user_notes_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "admin_user_notes_createdAt_idx" ON public.admin_user_notes USING btree ("createdAt");


--
-- Name: admin_user_notes_noteType_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "admin_user_notes_noteType_idx" ON public.admin_user_notes USING btree ("noteType");


--
-- Name: admin_user_notes_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "admin_user_notes_userId_idx" ON public.admin_user_notes USING btree ("userId");


--
-- Name: admin_wallet_transactions_adminWalletId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "admin_wallet_transactions_adminWalletId_idx" ON public.admin_wallet_transactions USING btree ("adminWalletId");


--
-- Name: admin_wallet_transactions_type_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX admin_wallet_transactions_type_idx ON public.admin_wallet_transactions USING btree (type);


--
-- Name: admin_wallet_transactions_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "admin_wallet_transactions_userId_idx" ON public.admin_wallet_transactions USING btree ("userId");


--
-- Name: admin_wallets_currency_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX admin_wallets_currency_key ON public.admin_wallets USING btree (currency);


--
-- Name: alert_policies_routeGroup_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "alert_policies_routeGroup_idx" ON public.alert_policies USING btree ("routeGroup");


--
-- Name: alert_policies_routeGroup_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "alert_policies_routeGroup_key" ON public.alert_policies USING btree ("routeGroup");


--
-- Name: analytics_events_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "analytics_events_createdAt_idx" ON public.analytics_events USING btree ("createdAt");


--
-- Name: analytics_events_eventName_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "analytics_events_eventName_idx" ON public.analytics_events USING btree ("eventName");


--
-- Name: analytics_events_sessionId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "analytics_events_sessionId_idx" ON public.analytics_events USING btree ("sessionId");


--
-- Name: analytics_events_timestamp_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX analytics_events_timestamp_idx ON public.analytics_events USING btree ("timestamp");


--
-- Name: analytics_events_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "analytics_events_userId_idx" ON public.analytics_events USING btree ("userId");


--
-- Name: audit_logs_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "audit_logs_createdAt_idx" ON public.audit_logs USING btree ("createdAt");


--
-- Name: audit_logs_resourceId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "audit_logs_resourceId_idx" ON public.audit_logs USING btree ("resourceId");


--
-- Name: audit_logs_resourceType_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "audit_logs_resourceType_idx" ON public.audit_logs USING btree ("resourceType");


--
-- Name: audit_logs_timestamp_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX audit_logs_timestamp_idx ON public.audit_logs USING btree ("timestamp");


--
-- Name: audit_logs_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "audit_logs_userId_idx" ON public.audit_logs USING btree ("userId");


--
-- Name: backup_codes_code_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX backup_codes_code_idx ON public.backup_codes USING btree (code);


--
-- Name: backup_codes_code_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX backup_codes_code_key ON public.backup_codes USING btree (code);


--
-- Name: backup_codes_isUsed_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "backup_codes_isUsed_idx" ON public.backup_codes USING btree ("isUsed");


--
-- Name: backup_codes_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "backup_codes_userId_idx" ON public.backup_codes USING btree ("userId");


--
-- Name: crypto_orders_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "crypto_orders_createdAt_idx" ON public.crypto_orders USING btree ("createdAt");


--
-- Name: crypto_orders_cryptoType_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "crypto_orders_cryptoType_idx" ON public.crypto_orders USING btree ("cryptoType");


--
-- Name: crypto_orders_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX crypto_orders_status_idx ON public.crypto_orders USING btree (status);


--
-- Name: crypto_orders_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "crypto_orders_userId_idx" ON public.crypto_orders USING btree ("userId");


--
-- Name: crypto_wallets_address_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX crypto_wallets_address_key ON public.crypto_wallets USING btree (address);


--
-- Name: crypto_wallets_currency_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX crypto_wallets_currency_idx ON public.crypto_wallets USING btree (currency);


--
-- Name: crypto_wallets_userId_currency_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "crypto_wallets_userId_currency_key" ON public.crypto_wallets USING btree ("userId", currency);


--
-- Name: crypto_wallets_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "crypto_wallets_userId_idx" ON public.crypto_wallets USING btree ("userId");


--
-- Name: crypto_withdrawals_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "crypto_withdrawals_createdAt_idx" ON public.crypto_withdrawals USING btree ("createdAt");


--
-- Name: crypto_withdrawals_cryptoType_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "crypto_withdrawals_cryptoType_idx" ON public.crypto_withdrawals USING btree ("cryptoType");


--
-- Name: crypto_withdrawals_currency_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX crypto_withdrawals_currency_idx ON public.crypto_withdrawals USING btree (currency);


--
-- Name: crypto_withdrawals_paymentProvider_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "crypto_withdrawals_paymentProvider_idx" ON public.crypto_withdrawals USING btree ("paymentProvider");


--
-- Name: crypto_withdrawals_requestedAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "crypto_withdrawals_requestedAt_idx" ON public.crypto_withdrawals USING btree ("requestedAt");


--
-- Name: crypto_withdrawals_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX crypto_withdrawals_status_idx ON public.crypto_withdrawals USING btree (status);


--
-- Name: crypto_withdrawals_status_requestedAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "crypto_withdrawals_status_requestedAt_idx" ON public.crypto_withdrawals USING btree (status, "requestedAt" DESC);


--
-- Name: crypto_withdrawals_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "crypto_withdrawals_userId_idx" ON public.crypto_withdrawals USING btree ("userId");


--
-- Name: crypto_withdrawals_userId_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "crypto_withdrawals_userId_status_idx" ON public.crypto_withdrawals USING btree ("userId", status);


--
-- Name: debit_cards_cardNumber_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "debit_cards_cardNumber_idx" ON public.debit_cards USING btree ("cardNumber");


--
-- Name: debit_cards_cardNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "debit_cards_cardNumber_key" ON public.debit_cards USING btree ("cardNumber");


--
-- Name: debit_cards_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "debit_cards_userId_idx" ON public.debit_cards USING btree ("userId");


--
-- Name: email_logs_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX email_logs_status_idx ON public.email_logs USING btree (status);


--
-- Name: email_logs_template_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX email_logs_template_idx ON public.email_logs USING btree (template);


--
-- Name: email_logs_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "email_logs_userId_idx" ON public.email_logs USING btree ("userId");


--
-- Name: eth_activity_addressNormalized_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "eth_activity_addressNormalized_idx" ON public.eth_activity USING btree ("addressNormalized");


--
-- Name: eth_activity_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "eth_activity_createdAt_idx" ON public.eth_activity USING btree ("createdAt");


--
-- Name: eth_activity_txHash_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "eth_activity_txHash_key" ON public.eth_activity USING btree ("txHash");


--
-- Name: eth_activity_type_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX eth_activity_type_idx ON public.eth_activity USING btree (type);


--
-- Name: fee_revenues_baseCurrency_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "fee_revenues_baseCurrency_idx" ON public.fee_revenues USING btree ("baseCurrency");


--
-- Name: fee_revenues_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "fee_revenues_createdAt_idx" ON public.fee_revenues USING btree ("createdAt");


--
-- Name: fee_revenues_transactionId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "fee_revenues_transactionId_key" ON public.fee_revenues USING btree ("transactionId");


--
-- Name: fee_revenues_transactionType_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "fee_revenues_transactionType_idx" ON public.fee_revenues USING btree ("transactionType");


--
-- Name: fee_revenues_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "fee_revenues_userId_idx" ON public.fee_revenues USING btree ("userId");


--
-- Name: fraud_alerts_alertType_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "fraud_alerts_alertType_idx" ON public.fraud_alerts USING btree ("alertType");


--
-- Name: fraud_alerts_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "fraud_alerts_createdAt_idx" ON public.fraud_alerts USING btree ("createdAt");


--
-- Name: fraud_alerts_resolved_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fraud_alerts_resolved_idx ON public.fraud_alerts USING btree (resolved);


--
-- Name: fraud_alerts_severity_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fraud_alerts_severity_idx ON public.fraud_alerts USING btree (severity);


--
-- Name: fraud_alerts_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "fraud_alerts_userId_idx" ON public.fraud_alerts USING btree ("userId");


--
-- Name: health_readings_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "health_readings_createdAt_idx" ON public.health_readings USING btree ("createdAt");


--
-- Name: health_readings_recordedAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "health_readings_recordedAt_idx" ON public.health_readings USING btree ("recordedAt");


--
-- Name: health_readings_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "health_readings_userId_idx" ON public.health_readings USING btree ("userId");


--
-- Name: invoice_items_invoiceId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "invoice_items_invoiceId_idx" ON public.invoice_items USING btree ("invoiceId");


--
-- Name: invoices_invoiceNumber_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "invoices_invoiceNumber_idx" ON public.invoices USING btree ("invoiceNumber");


--
-- Name: invoices_invoiceNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "invoices_invoiceNumber_key" ON public.invoices USING btree ("invoiceNumber");


--
-- Name: invoices_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX invoices_status_idx ON public.invoices USING btree (status);


--
-- Name: invoices_transactionId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "invoices_transactionId_key" ON public.invoices USING btree ("transactionId");


--
-- Name: invoices_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "invoices_userId_idx" ON public.invoices USING btree ("userId");


--
-- Name: ip_blocks_ip_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ip_blocks_ip_key ON public.ip_blocks USING btree (ip);


--
-- Name: ip_blocks_updatedAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ip_blocks_updatedAt_idx" ON public.ip_blocks USING btree ("updatedAt");


--
-- Name: ip_reputations_blacklisted_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ip_reputations_blacklisted_idx ON public.ip_reputations USING btree (blacklisted);


--
-- Name: ip_reputations_ipAddress_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ip_reputations_ipAddress_idx" ON public.ip_reputations USING btree ("ipAddress");


--
-- Name: ip_reputations_ipAddress_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ip_reputations_ipAddress_key" ON public.ip_reputations USING btree ("ipAddress");


--
-- Name: ip_reputations_riskScore_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ip_reputations_riskScore_idx" ON public.ip_reputations USING btree ("riskScore");


--
-- Name: kyc_verifications_kycLevel_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "kyc_verifications_kycLevel_idx" ON public.kyc_verifications USING btree ("kycLevel");


--
-- Name: kyc_verifications_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX kyc_verifications_status_idx ON public.kyc_verifications USING btree (status);


--
-- Name: kyc_verifications_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "kyc_verifications_userId_idx" ON public.kyc_verifications USING btree ("userId");


--
-- Name: kyc_verifications_userId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "kyc_verifications_userId_key" ON public.kyc_verifications USING btree ("userId");


--
-- Name: kyc_verifications_verifiedAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "kyc_verifications_verifiedAt_idx" ON public.kyc_verifications USING btree ("verifiedAt");


--
-- Name: loans_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "loans_createdAt_idx" ON public.loans USING btree ("createdAt");


--
-- Name: loans_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX loans_status_idx ON public.loans USING btree (status);


--
-- Name: loans_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "loans_userId_idx" ON public.loans USING btree ("userId");


--
-- Name: medbeds_bookings_paymentStatus_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "medbeds_bookings_paymentStatus_idx" ON public.medbeds_bookings USING btree ("paymentStatus");


--
-- Name: medbeds_bookings_sessionDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "medbeds_bookings_sessionDate_idx" ON public.medbeds_bookings USING btree ("sessionDate");


--
-- Name: medbeds_bookings_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX medbeds_bookings_status_idx ON public.medbeds_bookings USING btree (status);


--
-- Name: medbeds_bookings_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "medbeds_bookings_userId_idx" ON public.medbeds_bookings USING btree ("userId");


--
-- Name: notification_logs_channel_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX notification_logs_channel_idx ON public.notification_logs USING btree (channel);


--
-- Name: notification_logs_notificationId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "notification_logs_notificationId_idx" ON public.notification_logs USING btree ("notificationId");


--
-- Name: notification_logs_sentAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "notification_logs_sentAt_idx" ON public.notification_logs USING btree ("sentAt");


--
-- Name: notification_logs_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX notification_logs_status_idx ON public.notification_logs USING btree (status);


--
-- Name: notification_preferences_userId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "notification_preferences_userId_key" ON public.notification_preferences USING btree ("userId");


--
-- Name: notifications_category_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX notifications_category_idx ON public.notifications USING btree (category);


--
-- Name: notifications_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "notifications_createdAt_idx" ON public.notifications USING btree ("createdAt");


--
-- Name: notifications_isRead_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "notifications_isRead_idx" ON public.notifications USING btree ("isRead");


--
-- Name: notifications_priority_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX notifications_priority_idx ON public.notifications USING btree (priority);


--
-- Name: notifications_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "notifications_userId_idx" ON public.notifications USING btree ("userId");


--
-- Name: oal_audit_log_action_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX oal_audit_log_action_idx ON public.oal_audit_log USING btree (action);


--
-- Name: oal_audit_log_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "oal_audit_log_createdAt_idx" ON public.oal_audit_log USING btree ("createdAt");


--
-- Name: oal_audit_log_createdById_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "oal_audit_log_createdById_idx" ON public.oal_audit_log USING btree ("createdById");


--
-- Name: oal_audit_log_location_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX oal_audit_log_location_idx ON public.oal_audit_log USING btree (location);


--
-- Name: oal_audit_log_object_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX oal_audit_log_object_idx ON public.oal_audit_log USING btree (object);


--
-- Name: oal_audit_log_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX oal_audit_log_status_idx ON public.oal_audit_log USING btree (status);


--
-- Name: oal_audit_log_subjectId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "oal_audit_log_subjectId_idx" ON public.oal_audit_log USING btree ("subjectId");


--
-- Name: password_reset_requests_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "password_reset_requests_createdAt_idx" ON public.password_reset_requests USING btree ("createdAt");


--
-- Name: password_reset_requests_email_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX password_reset_requests_email_idx ON public.password_reset_requests USING btree (email);


--
-- Name: password_reset_requests_token_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX password_reset_requests_token_idx ON public.password_reset_requests USING btree (token);


--
-- Name: password_reset_requests_token_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX password_reset_requests_token_key ON public.password_reset_requests USING btree (token);


--
-- Name: password_reset_requests_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "password_reset_requests_userId_idx" ON public.password_reset_requests USING btree ("userId");


--
-- Name: payment_sessions_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "payment_sessions_createdAt_idx" ON public.payment_sessions USING btree ("createdAt");


--
-- Name: payment_sessions_expiresAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "payment_sessions_expiresAt_idx" ON public.payment_sessions USING btree ("expiresAt");


--
-- Name: payment_sessions_sessionId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "payment_sessions_sessionId_idx" ON public.payment_sessions USING btree ("sessionId");


--
-- Name: payment_sessions_sessionId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "payment_sessions_sessionId_key" ON public.payment_sessions USING btree ("sessionId");


--
-- Name: payment_sessions_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX payment_sessions_status_idx ON public.payment_sessions USING btree (status);


--
-- Name: payment_sessions_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "payment_sessions_userId_idx" ON public.payment_sessions USING btree ("userId");


--
-- Name: policy_audit_logs_changedBy_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "policy_audit_logs_changedBy_idx" ON public.policy_audit_logs USING btree ("changedBy");


--
-- Name: policy_audit_logs_entryHash_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "policy_audit_logs_entryHash_idx" ON public.policy_audit_logs USING btree ("entryHash");


--
-- Name: policy_audit_logs_policyId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "policy_audit_logs_policyId_idx" ON public.policy_audit_logs USING btree ("policyId");


--
-- Name: policy_audit_logs_timestamp_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX policy_audit_logs_timestamp_idx ON public.policy_audit_logs USING btree ("timestamp");


--
-- Name: push_subscriptions_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "push_subscriptions_isActive_idx" ON public.push_subscriptions USING btree ("isActive");


--
-- Name: push_subscriptions_userId_endpoint_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "push_subscriptions_userId_endpoint_key" ON public.push_subscriptions USING btree ("userId", endpoint);


--
-- Name: push_subscriptions_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "push_subscriptions_userId_idx" ON public.push_subscriptions USING btree ("userId");


--
-- Name: rewards_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "rewards_createdAt_idx" ON public.rewards USING btree ("createdAt");


--
-- Name: rewards_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rewards_status_idx ON public.rewards USING btree (status);


--
-- Name: rewards_type_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rewards_type_idx ON public.rewards USING btree (type);


--
-- Name: rewards_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "rewards_userId_idx" ON public.rewards USING btree ("userId");


--
-- Name: sessions_token_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sessions_token_idx ON public.sessions USING btree (token);


--
-- Name: sessions_token_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX sessions_token_key ON public.sessions USING btree (token);


--
-- Name: sessions_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "sessions_userId_idx" ON public.sessions USING btree ("userId");


--
-- Name: support_tickets_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX support_tickets_status_idx ON public.support_tickets USING btree (status);


--
-- Name: support_tickets_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "support_tickets_userId_idx" ON public.support_tickets USING btree ("userId");


--
-- Name: system_alerts_alertType_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "system_alerts_alertType_idx" ON public.system_alerts USING btree ("alertType");


--
-- Name: system_alerts_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "system_alerts_createdAt_idx" ON public.system_alerts USING btree ("createdAt");


--
-- Name: system_alerts_isResolved_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "system_alerts_isResolved_idx" ON public.system_alerts USING btree ("isResolved");


--
-- Name: system_alerts_severity_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX system_alerts_severity_idx ON public.system_alerts USING btree (severity);


--
-- Name: system_config_key_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX system_config_key_key ON public.system_config USING btree (key);


--
-- Name: system_status_alertLevel_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "system_status_alertLevel_idx" ON public.system_status USING btree ("alertLevel");


--
-- Name: system_status_lastChecked_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "system_status_lastChecked_idx" ON public.system_status USING btree ("lastChecked");


--
-- Name: system_status_serviceName_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "system_status_serviceName_idx" ON public.system_status USING btree ("serviceName");


--
-- Name: system_status_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX system_status_status_idx ON public.system_status USING btree (status);


--
-- Name: token_transactions_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "token_transactions_createdAt_idx" ON public.token_transactions USING btree ("createdAt");


--
-- Name: token_transactions_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX token_transactions_status_idx ON public.token_transactions USING btree (status);


--
-- Name: token_transactions_type_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX token_transactions_type_idx ON public.token_transactions USING btree (type);


--
-- Name: token_transactions_walletId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "token_transactions_walletId_idx" ON public.token_transactions USING btree ("walletId");


--
-- Name: token_wallets_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "token_wallets_userId_idx" ON public.token_wallets USING btree ("userId");


--
-- Name: token_wallets_userId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "token_wallets_userId_key" ON public.token_wallets USING btree ("userId");


--
-- Name: transaction_fees_active_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX transaction_fees_active_idx ON public.transaction_fees USING btree (active);


--
-- Name: transaction_fees_currency_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX transaction_fees_currency_idx ON public.transaction_fees USING btree (currency);


--
-- Name: transaction_fees_feeType_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "transaction_fees_feeType_idx" ON public.transaction_fees USING btree ("feeType");


--
-- Name: transaction_fees_priority_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX transaction_fees_priority_idx ON public.transaction_fees USING btree (priority);


--
-- Name: transactions_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "transactions_createdAt_idx" ON public.transactions USING btree ("createdAt");


--
-- Name: transactions_orderId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "transactions_orderId_idx" ON public.transactions USING btree ("orderId");


--
-- Name: transactions_orderId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "transactions_orderId_key" ON public.transactions USING btree ("orderId");


--
-- Name: transactions_provider_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX transactions_provider_idx ON public.transactions USING btree (provider);


--
-- Name: transactions_status_type_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX transactions_status_type_idx ON public.transactions USING btree (status, type);


--
-- Name: transactions_userId_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "transactions_userId_createdAt_idx" ON public.transactions USING btree ("userId", "createdAt" DESC);


--
-- Name: transactions_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "transactions_userId_idx" ON public.transactions USING btree ("userId");


--
-- Name: trustpilot_reviews_reviewId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "trustpilot_reviews_reviewId_key" ON public.trustpilot_reviews USING btree ("reviewId");


--
-- Name: two_factor_auth_userId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "two_factor_auth_userId_key" ON public.two_factor_auth USING btree ("userId");


--
-- Name: user_activities_action_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX user_activities_action_idx ON public.user_activities USING btree (action);


--
-- Name: user_activities_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "user_activities_createdAt_idx" ON public.user_activities USING btree ("createdAt");


--
-- Name: user_activities_email_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX user_activities_email_idx ON public.user_activities USING btree (email);


--
-- Name: user_activities_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "user_activities_userId_idx" ON public.user_activities USING btree ("userId");


--
-- Name: user_profiles_userId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "user_profiles_userId_key" ON public.user_profiles USING btree ("userId");


--
-- Name: user_tiers_currentTier_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "user_tiers_currentTier_idx" ON public.user_tiers USING btree ("currentTier");


--
-- Name: user_tiers_points_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX user_tiers_points_idx ON public.user_tiers USING btree (points);


--
-- Name: user_tiers_referralCode_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "user_tiers_referralCode_idx" ON public.user_tiers USING btree ("referralCode");


--
-- Name: user_tiers_referralCode_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "user_tiers_referralCode_key" ON public.user_tiers USING btree ("referralCode");


--
-- Name: user_tiers_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "user_tiers_userId_idx" ON public.user_tiers USING btree ("userId");


--
-- Name: user_tiers_userId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "user_tiers_userId_key" ON public.user_tiers USING btree ("userId");


--
-- Name: users_active_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_active_idx ON public.users USING btree (active);


--
-- Name: users_emailSignupToken_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "users_emailSignupToken_key" ON public.users USING btree ("emailSignupToken");


--
-- Name: users_emailVerified_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "users_emailVerified_idx" ON public.users USING btree ("emailVerified");


--
-- Name: users_email_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_email_idx ON public.users USING btree (email);


--
-- Name: users_email_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);


--
-- Name: users_ethWalletAddress_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "users_ethWalletAddress_key" ON public.users USING btree ("ethWalletAddress");


--
-- Name: users_role_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_role_idx ON public.users USING btree (role);


--
-- Name: users_stripeCustomerId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "users_stripeCustomerId_key" ON public.users USING btree ("stripeCustomerId");


--
-- Name: users_username_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_username_key ON public.users USING btree (username);


--
-- Name: whitelisted_addresses_userId_address_currency_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "whitelisted_addresses_userId_address_currency_key" ON public.whitelisted_addresses USING btree ("userId", address, currency);


--
-- Name: whitelisted_addresses_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "whitelisted_addresses_userId_idx" ON public.whitelisted_addresses USING btree ("userId");


--
-- Name: whitelisted_addresses_verified_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX whitelisted_addresses_verified_idx ON public.whitelisted_addresses USING btree (verified);


--
-- Name: withdrawal_queue_estimatedTime_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "withdrawal_queue_estimatedTime_idx" ON public.withdrawal_queue USING btree ("estimatedTime");


--
-- Name: withdrawal_queue_priority_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX withdrawal_queue_priority_idx ON public.withdrawal_queue USING btree (priority);


--
-- Name: withdrawal_queue_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX withdrawal_queue_status_idx ON public.withdrawal_queue USING btree (status);


--
-- Name: withdrawal_queue_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "withdrawal_queue_userId_idx" ON public.withdrawal_queue USING btree ("userId");


--
-- Name: withdrawal_queue_withdrawalId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "withdrawal_queue_withdrawalId_idx" ON public.withdrawal_queue USING btree ("withdrawalId");


--
-- Name: withdrawal_queue_withdrawalId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "withdrawal_queue_withdrawalId_key" ON public.withdrawal_queue USING btree ("withdrawalId");


--
-- Name: RPAExecution RPAExecution_workflowId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."RPAExecution"
    ADD CONSTRAINT "RPAExecution_workflowId_fkey" FOREIGN KEY ("workflowId") REFERENCES public."RPAWorkflow"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: RPAWorkflow RPAWorkflow_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."RPAWorkflow"
    ADD CONSTRAINT "RPAWorkflow_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: admin_wallet_transactions admin_wallet_transactions_adminWalletId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_wallet_transactions
    ADD CONSTRAINT "admin_wallet_transactions_adminWalletId_fkey" FOREIGN KEY ("adminWalletId") REFERENCES public.admin_wallets(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: admin_wallet_transactions admin_wallet_transactions_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_wallet_transactions
    ADD CONSTRAINT "admin_wallet_transactions_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: crypto_wallets crypto_wallets_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.crypto_wallets
    ADD CONSTRAINT "crypto_wallets_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: crypto_withdrawals crypto_withdrawals_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.crypto_withdrawals
    ADD CONSTRAINT "crypto_withdrawals_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: email_logs email_logs_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_logs
    ADD CONSTRAINT "email_logs_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: invoice_items invoice_items_invoiceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT "invoice_items_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES public.invoices(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: invoices invoices_transactionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT "invoices_transactionId_fkey" FOREIGN KEY ("transactionId") REFERENCES public.transactions(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: invoices invoices_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT "invoices_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: medbeds_bookings medbeds_bookings_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medbeds_bookings
    ADD CONSTRAINT "medbeds_bookings_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: policy_audit_logs policy_audit_logs_policyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.policy_audit_logs
    ADD CONSTRAINT "policy_audit_logs_policyId_fkey" FOREIGN KEY ("policyId") REFERENCES public.alert_policies(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: trustpilot_reviews trustpilot_reviews_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trustpilot_reviews
    ADD CONSTRAINT "trustpilot_reviews_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: two_factor_auth two_factor_auth_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.two_factor_auth
    ADD CONSTRAINT "two_factor_auth_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_profiles user_profiles_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT "user_profiles_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: whitelisted_addresses whitelisted_addresses_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.whitelisted_addresses
    ADD CONSTRAINT "whitelisted_addresses_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict eWhiOmFzNBmNxXed230CoXreH4Ns5que0MCli3sYFu7WX8CbnWDgzHDDw0MY422


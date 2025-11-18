--
-- PostgreSQL database dump
--

\restrict tVj94dO74QvqwfMcrR4IKSmEqvhDTqZm1hzAUP5b9xe8Jv5WZ83XDYyyPmIoDOr

-- Dumped from database version 15.15
-- Dumped by pg_dump version 15.15

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
-- Name: Role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."Role" AS ENUM (
    'USER',
    'STAFF',
    'ADMIN'
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
    updated_at timestamp(3) without time zone
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
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
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
    "updatedAt" timestamp(3) without time zone NOT NULL
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
    user_notes text
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
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.transactions OWNER TO postgres;

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
    "stripeCustomerId" text
);


ALTER TABLE public.users OWNER TO postgres;

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

COPY public."CryptoPayments" (id, user_id, invoice_id, amount, currency, status, payment_url, order_id, description, paid_at, created_at, updated_at) FROM stdin;
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
8702e36e-7a39-4389-9dad-cec67c3a5f55	49cac26869a3773aa16ce837edef9e12211abe6df9333d2ce63caff95318ed0c	2025-11-17 22:07:37.037698+00	20251109112848_init	\N	\N	2025-11-17 22:07:35.365238+00	1
26ebe799-4e97-4a48-af58-9714dc0d3410	2a3b8c898245042c7d19f67a79c801b989b47c399a75b0e664ba3025e219fd9e	2025-11-17 22:07:37.100549+00	20251109121700_test_init	\N	\N	2025-11-17 22:07:37.043272+00	1
e4eca20b-dd6b-4680-a671-3b7f0882b577	754976be5b8ef281659fa744e5641887f2ab5d8ef33286900dc5153ed971c08a	2025-11-17 22:07:37.486453+00	20251111015408_add_analytics_events	\N	\N	2025-11-17 22:07:37.105521+00	1
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
-- Data for Name: analytics_events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.analytics_events (id, "userId", "sessionId", "eventName", "eventProperties", "userProperties", "deviceInfo", "timestamp", "ipAddress", "userAgent", referrer, url, platform, "appVersion", "createdAt") FROM stdin;
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit_logs (id, "userId", action, "resourceType", "resourceId", changes, "previousValues", "newValues", metadata, "ipAddress", "userAgent", "timestamp", "createdAt") FROM stdin;
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

COPY public.crypto_wallets (id, "userId", currency, balance, address, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: crypto_withdrawals; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.crypto_withdrawals (id, "userId", "cryptoType", "cryptoAmount", "usdEquivalent", "withdrawalAddress", status, "adminApprovedBy", "adminNotes", "txHash", "networkFee", "approvedAt", "rejectedAt", "completedAt", "cancelledAt", "createdAt", "updatedAt", user_notes) FROM stdin;
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
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transactions (id, "userId", amount, type, description, category, status, "createdAt", "updatedAt") FROM stdin;
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

COPY public.users (id, email, username, "passwordHash", "firstName", "lastName", role, "usdBalance", active, "emailVerified", "emailVerifiedAt", "lastLogin", "termsAccepted", "termsAcceptedAt", "totpSecret", "totpEnabled", "totpVerified", "backupCodes", "ethWalletAddress", "createdAt", "updatedAt", "btcBalance", "ethBalance", "usdtBalance", address, approved, "approvedAt", "approvedBy", city, country, "phoneNumber", "postalCode", "profileImage", "rejectedAt", "rejectionReason", "emailSignupToken", "emailSignupTokenExpiry", "firstLoginCompleted", "signupMethod", "stripeCustomerId") FROM stdin;
a5ea5660-ef01-4e5f-9c72-7c935b943653	admin@advancia.com	admin	$2a$12$FDsbG8ZWgFlO3HPMRmtG5.bHFpFBFJaeCvPdsIxqff83dEdO7m9GO	\N	\N	ADMIN	0.000000000000000000000000000000	t	f	\N	\N	f	\N	NR3UW6DXGBLFIJJ7JE3TQKTLKYYHWW2G	t	t	["$2a$12$Rl8n5purPSY76ddpS/910.1M3zt1CgPufR/g1wFfxYe68bBGYt9rm","$2a$12$pzdjW/PPH9wXc6IYFBeVTOnxaqSoXyQzB.7e9mh8WvLT3ZwLR8Cc6","$2a$12$SOCQt0Ih0NtSjWbYFLVDqOTsqyqGCWRKUees2tTMtxeRHz3.gx46q","$2a$12$TSI6jcITLrv4NqE1E/TB3Om/SRXdQGRfRTmVsGInRunyrvR/TtWIS","$2a$12$rX06TiSlruf1pLnH85kLMeyezmEcByyiQk0edxaGJojDc8b7ciVpu"]	\N	2025-11-17 23:06:38.685	2025-11-17 23:06:38.685	0.000000000000000000000000000000	0.000000000000000000000000000000	0.000000000000000000000000000000	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	password	\N
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
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


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
-- Name: crypto_withdrawals_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX crypto_withdrawals_status_idx ON public.crypto_withdrawals USING btree (status);


--
-- Name: crypto_withdrawals_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "crypto_withdrawals_userId_idx" ON public.crypto_withdrawals USING btree ("userId");


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
-- Name: transactions_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "transactions_createdAt_idx" ON public.transactions USING btree ("createdAt");


--
-- Name: transactions_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "transactions_userId_idx" ON public.transactions USING btree ("userId");


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
-- Name: users_emailSignupToken_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "users_emailSignupToken_key" ON public.users USING btree ("emailSignupToken");


--
-- Name: users_email_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);


--
-- Name: users_ethWalletAddress_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "users_ethWalletAddress_key" ON public.users USING btree ("ethWalletAddress");


--
-- Name: users_stripeCustomerId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "users_stripeCustomerId_key" ON public.users USING btree ("stripeCustomerId");


--
-- Name: users_username_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_username_key ON public.users USING btree (username);


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
-- PostgreSQL database dump complete
--

\unrestrict tVj94dO74QvqwfMcrR4IKSmEqvhDTqZm1hzAUP5b9xe8Jv5WZ83XDYyyPmIoDOr


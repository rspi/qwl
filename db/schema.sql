SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: companion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.companion (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);


--
-- Name: companion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.companion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: companion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.companion_id_seq OWNED BY public.companion.id;


--
-- Name: feeling; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feeling (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);


--
-- Name: feeling_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.feeling_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: feeling_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.feeling_id_seq OWNED BY public.feeling.id;


--
-- Name: location; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.location (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);


--
-- Name: location_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.location_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: location_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.location_id_seq OWNED BY public.location.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying(128) NOT NULL
);


--
-- Name: workout_session; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workout_session (
    id integer NOT NULL,
    workout_date date NOT NULL,
    start_time time without time zone,
    end_time time without time zone,
    duration_minutes integer NOT NULL,
    location_id integer,
    feeling_id integer,
    effort integer,
    CONSTRAINT workout_session_effort_check CHECK (((effort >= 1) AND (effort <= 5)))
);


--
-- Name: workout_session_companion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workout_session_companion (
    workout_session_id integer NOT NULL,
    companion_id integer NOT NULL
);


--
-- Name: workout_session_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.workout_session_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workout_session_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.workout_session_id_seq OWNED BY public.workout_session.id;


--
-- Name: workout_session_workout_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workout_session_workout_type (
    workout_session_id integer NOT NULL,
    workout_type_id integer NOT NULL
);


--
-- Name: workout_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workout_type (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);


--
-- Name: workout_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.workout_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workout_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.workout_type_id_seq OWNED BY public.workout_type.id;


--
-- Name: companion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companion ALTER COLUMN id SET DEFAULT nextval('public.companion_id_seq'::regclass);


--
-- Name: feeling id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feeling ALTER COLUMN id SET DEFAULT nextval('public.feeling_id_seq'::regclass);


--
-- Name: location id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location ALTER COLUMN id SET DEFAULT nextval('public.location_id_seq'::regclass);


--
-- Name: workout_session id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workout_session ALTER COLUMN id SET DEFAULT nextval('public.workout_session_id_seq'::regclass);


--
-- Name: workout_type id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workout_type ALTER COLUMN id SET DEFAULT nextval('public.workout_type_id_seq'::regclass);


--
-- Name: companion companion_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companion
    ADD CONSTRAINT companion_name_key UNIQUE (name);


--
-- Name: companion companion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companion
    ADD CONSTRAINT companion_pkey PRIMARY KEY (id);


--
-- Name: feeling feeling_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feeling
    ADD CONSTRAINT feeling_name_key UNIQUE (name);


--
-- Name: feeling feeling_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feeling
    ADD CONSTRAINT feeling_pkey PRIMARY KEY (id);


--
-- Name: location location_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location
    ADD CONSTRAINT location_name_key UNIQUE (name);


--
-- Name: location location_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location
    ADD CONSTRAINT location_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: workout_session_companion workout_session_companion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workout_session_companion
    ADD CONSTRAINT workout_session_companion_pkey PRIMARY KEY (workout_session_id, companion_id);


--
-- Name: workout_session workout_session_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workout_session
    ADD CONSTRAINT workout_session_pkey PRIMARY KEY (id);


--
-- Name: workout_session_workout_type workout_session_workout_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workout_session_workout_type
    ADD CONSTRAINT workout_session_workout_type_pkey PRIMARY KEY (workout_session_id, workout_type_id);


--
-- Name: workout_type workout_type_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workout_type
    ADD CONSTRAINT workout_type_name_key UNIQUE (name);


--
-- Name: workout_type workout_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workout_type
    ADD CONSTRAINT workout_type_pkey PRIMARY KEY (id);


--
-- Name: idx_workout_session_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_workout_session_date ON public.workout_session USING btree (workout_date);


--
-- Name: idx_workout_session_location; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_workout_session_location ON public.workout_session USING btree (location_id);


--
-- Name: workout_session_companion workout_session_companion_companion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workout_session_companion
    ADD CONSTRAINT workout_session_companion_companion_id_fkey FOREIGN KEY (companion_id) REFERENCES public.companion(id) ON DELETE CASCADE;


--
-- Name: workout_session_companion workout_session_companion_workout_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workout_session_companion
    ADD CONSTRAINT workout_session_companion_workout_session_id_fkey FOREIGN KEY (workout_session_id) REFERENCES public.workout_session(id) ON DELETE CASCADE;


--
-- Name: workout_session workout_session_feeling_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workout_session
    ADD CONSTRAINT workout_session_feeling_id_fkey FOREIGN KEY (feeling_id) REFERENCES public.feeling(id) ON DELETE SET NULL;


--
-- Name: workout_session workout_session_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workout_session
    ADD CONSTRAINT workout_session_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.location(id) ON DELETE SET NULL;


--
-- Name: workout_session_workout_type workout_session_workout_type_workout_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workout_session_workout_type
    ADD CONSTRAINT workout_session_workout_type_workout_session_id_fkey FOREIGN KEY (workout_session_id) REFERENCES public.workout_session(id) ON DELETE CASCADE;


--
-- Name: workout_session_workout_type workout_session_workout_type_workout_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workout_session_workout_type
    ADD CONSTRAINT workout_session_workout_type_workout_type_id_fkey FOREIGN KEY (workout_type_id) REFERENCES public.workout_type(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


--
-- Dbmate schema migrations
--

INSERT INTO public.schema_migrations (version) VALUES
    ('20260731000000');

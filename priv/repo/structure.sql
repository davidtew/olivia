--
-- PostgreSQL database dump
--

\restrict pnNeHZdijrgrQiwnTR40UHDLmZY9qZVUmvX9LPnTXcgQTqlJvWIcjYpO1L4rwwT

-- Dumped from database version 17.7 (Homebrew)
-- Dumped by pg_dump version 17.7 (Homebrew)

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

--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: artworks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.artworks (
    id bigint NOT NULL,
    title character varying(255) NOT NULL,
    slug character varying(255) NOT NULL,
    year integer,
    medium character varying(255),
    dimensions character varying(255),
    status character varying(255) DEFAULT 'available'::character varying NOT NULL,
    price_cents integer,
    currency character varying(255) DEFAULT 'GBP'::character varying,
    location character varying(255),
    description_md text,
    "position" integer DEFAULT 0 NOT NULL,
    featured boolean DEFAULT false NOT NULL,
    published boolean DEFAULT false NOT NULL,
    series_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    image_url text,
    media_file_id bigint
);


--
-- Name: artworks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.artworks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artworks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.artworks_id_seq OWNED BY public.artworks.id;


--
-- Name: client_projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.client_projects (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    client_name character varying(255),
    location character varying(255),
    status character varying(255),
    description_md text,
    "position" integer DEFAULT 0 NOT NULL,
    published boolean DEFAULT false NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: client_projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.client_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: client_projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.client_projects_id_seq OWNED BY public.client_projects.id;


--
-- Name: enquiries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.enquiries (
    id bigint NOT NULL,
    type character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    message text NOT NULL,
    meta jsonb,
    artwork_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: enquiries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.enquiries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: enquiries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.enquiries_id_seq OWNED BY public.enquiries.id;


--
-- Name: exhibitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exhibitions (
    id bigint NOT NULL,
    title character varying(255) NOT NULL,
    venue character varying(255),
    city character varying(255),
    country character varying(255),
    start_date date,
    end_date date,
    description_md text,
    "position" integer DEFAULT 0 NOT NULL,
    published boolean DEFAULT false NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: exhibitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.exhibitions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exhibitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.exhibitions_id_seq OWNED BY public.exhibitions.id;


--
-- Name: media; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.media (
    id bigint NOT NULL,
    filename character varying(255) NOT NULL,
    url character varying(255) NOT NULL,
    content_type character varying(255),
    file_size integer,
    width integer,
    height integer,
    alt_text character varying(255),
    caption text,
    tags character varying(255)[] DEFAULT ARRAY[]::character varying[],
    user_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    status character varying(255) DEFAULT 'quarantine'::character varying NOT NULL,
    asset_type character varying(255),
    asset_role character varying(255),
    metadata jsonb DEFAULT '{}'::jsonb
);


--
-- Name: media_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.media_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: media_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.media_id_seq OWNED BY public.media.id;


--
-- Name: media_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.media_images (
    id bigint NOT NULL,
    role character varying(255) DEFAULT 'main'::character varying NOT NULL,
    original_url character varying(255) NOT NULL,
    large_url character varying(255),
    medium_url character varying(255),
    thumb_url character varying(255),
    alt_text character varying(255),
    "position" integer DEFAULT 0 NOT NULL,
    artwork_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    media_file_id bigint
);


--
-- Name: media_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.media_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: media_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.media_images_id_seq OWNED BY public.media_images.id;


--
-- Name: newsletters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.newsletters (
    id bigint NOT NULL,
    subject character varying(255) NOT NULL,
    body_md text NOT NULL,
    status character varying(255) DEFAULT 'draft'::character varying NOT NULL,
    sent_at timestamp(0) without time zone,
    sent_count integer DEFAULT 0,
    user_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: newsletters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.newsletters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: newsletters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.newsletters_id_seq OWNED BY public.newsletters.id;


--
-- Name: page_sections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.page_sections (
    id bigint NOT NULL,
    key character varying(255) NOT NULL,
    content_md text,
    "position" integer DEFAULT 0 NOT NULL,
    page_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: page_sections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.page_sections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: page_sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.page_sections_id_seq OWNED BY public.page_sections.id;


--
-- Name: pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pages (
    id bigint NOT NULL,
    slug character varying(255) NOT NULL,
    title character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pages_id_seq OWNED BY public.pages.id;


--
-- Name: press_features; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.press_features (
    id bigint NOT NULL,
    title character varying(255) NOT NULL,
    publication character varying(255),
    issue character varying(255),
    date date,
    url character varying(255),
    excerpt_md text,
    "position" integer DEFAULT 0 NOT NULL,
    published boolean DEFAULT false NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: press_features_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.press_features_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: press_features_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.press_features_id_seq OWNED BY public.press_features.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: series; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.series (
    id bigint NOT NULL,
    title character varying(255) NOT NULL,
    slug character varying(255) NOT NULL,
    summary text,
    body_md text,
    "position" integer DEFAULT 0 NOT NULL,
    published boolean DEFAULT false NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    cover_image_url text,
    media_file_id bigint
);


--
-- Name: series_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.series_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: series_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.series_id_seq OWNED BY public.series.id;


--
-- Name: subscribers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscribers (
    id bigint NOT NULL,
    email public.citext NOT NULL,
    source character varying(255) DEFAULT 'website_form'::character varying,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: subscribers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subscribers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subscribers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subscribers_id_seq OWNED BY public.subscribers.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email public.citext NOT NULL,
    confirmed_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: users_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_tokens (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    token bytea NOT NULL,
    context character varying(255) NOT NULL,
    sent_to character varying(255),
    authenticated_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL
);


--
-- Name: users_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_tokens_id_seq OWNED BY public.users_tokens.id;


--
-- Name: artworks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artworks ALTER COLUMN id SET DEFAULT nextval('public.artworks_id_seq'::regclass);


--
-- Name: client_projects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_projects ALTER COLUMN id SET DEFAULT nextval('public.client_projects_id_seq'::regclass);


--
-- Name: enquiries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enquiries ALTER COLUMN id SET DEFAULT nextval('public.enquiries_id_seq'::regclass);


--
-- Name: exhibitions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exhibitions ALTER COLUMN id SET DEFAULT nextval('public.exhibitions_id_seq'::regclass);


--
-- Name: media id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media ALTER COLUMN id SET DEFAULT nextval('public.media_id_seq'::regclass);


--
-- Name: media_images id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_images ALTER COLUMN id SET DEFAULT nextval('public.media_images_id_seq'::regclass);


--
-- Name: newsletters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletters ALTER COLUMN id SET DEFAULT nextval('public.newsletters_id_seq'::regclass);


--
-- Name: page_sections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_sections ALTER COLUMN id SET DEFAULT nextval('public.page_sections_id_seq'::regclass);


--
-- Name: pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages ALTER COLUMN id SET DEFAULT nextval('public.pages_id_seq'::regclass);


--
-- Name: press_features id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.press_features ALTER COLUMN id SET DEFAULT nextval('public.press_features_id_seq'::regclass);


--
-- Name: series id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.series ALTER COLUMN id SET DEFAULT nextval('public.series_id_seq'::regclass);


--
-- Name: subscribers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscribers ALTER COLUMN id SET DEFAULT nextval('public.subscribers_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: users_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_tokens ALTER COLUMN id SET DEFAULT nextval('public.users_tokens_id_seq'::regclass);


--
-- Name: artworks artworks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artworks
    ADD CONSTRAINT artworks_pkey PRIMARY KEY (id);


--
-- Name: client_projects client_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_projects
    ADD CONSTRAINT client_projects_pkey PRIMARY KEY (id);


--
-- Name: enquiries enquiries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enquiries
    ADD CONSTRAINT enquiries_pkey PRIMARY KEY (id);


--
-- Name: exhibitions exhibitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exhibitions
    ADD CONSTRAINT exhibitions_pkey PRIMARY KEY (id);


--
-- Name: media_images media_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_images
    ADD CONSTRAINT media_images_pkey PRIMARY KEY (id);


--
-- Name: media media_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media
    ADD CONSTRAINT media_pkey PRIMARY KEY (id);


--
-- Name: newsletters newsletters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletters
    ADD CONSTRAINT newsletters_pkey PRIMARY KEY (id);


--
-- Name: page_sections page_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_sections
    ADD CONSTRAINT page_sections_pkey PRIMARY KEY (id);


--
-- Name: pages pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id);


--
-- Name: press_features press_features_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.press_features
    ADD CONSTRAINT press_features_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: series series_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.series
    ADD CONSTRAINT series_pkey PRIMARY KEY (id);


--
-- Name: subscribers subscribers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscribers
    ADD CONSTRAINT subscribers_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users_tokens users_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_tokens
    ADD CONSTRAINT users_tokens_pkey PRIMARY KEY (id);


--
-- Name: artworks_featured_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX artworks_featured_index ON public.artworks USING btree (featured);


--
-- Name: artworks_media_file_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX artworks_media_file_id_index ON public.artworks USING btree (media_file_id);


--
-- Name: artworks_position_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX artworks_position_index ON public.artworks USING btree ("position");


--
-- Name: artworks_published_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX artworks_published_index ON public.artworks USING btree (published);


--
-- Name: artworks_series_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX artworks_series_id_index ON public.artworks USING btree (series_id);


--
-- Name: artworks_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX artworks_slug_index ON public.artworks USING btree (slug);


--
-- Name: artworks_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX artworks_status_index ON public.artworks USING btree (status);


--
-- Name: client_projects_position_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX client_projects_position_index ON public.client_projects USING btree ("position");


--
-- Name: client_projects_published_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX client_projects_published_index ON public.client_projects USING btree (published);


--
-- Name: client_projects_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX client_projects_status_index ON public.client_projects USING btree (status);


--
-- Name: enquiries_artwork_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX enquiries_artwork_id_index ON public.enquiries USING btree (artwork_id);


--
-- Name: enquiries_inserted_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX enquiries_inserted_at_index ON public.enquiries USING btree (inserted_at);


--
-- Name: enquiries_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX enquiries_type_index ON public.enquiries USING btree (type);


--
-- Name: exhibitions_position_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX exhibitions_position_index ON public.exhibitions USING btree ("position");


--
-- Name: exhibitions_published_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX exhibitions_published_index ON public.exhibitions USING btree (published);


--
-- Name: exhibitions_start_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX exhibitions_start_date_index ON public.exhibitions USING btree (start_date);


--
-- Name: media_asset_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX media_asset_type_index ON public.media USING btree (asset_type);


--
-- Name: media_images_artwork_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX media_images_artwork_id_index ON public.media_images USING btree (artwork_id);


--
-- Name: media_images_media_file_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX media_images_media_file_id_index ON public.media_images USING btree (media_file_id);


--
-- Name: media_images_position_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX media_images_position_index ON public.media_images USING btree ("position");


--
-- Name: media_images_role_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX media_images_role_index ON public.media_images USING btree (role);


--
-- Name: media_inserted_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX media_inserted_at_index ON public.media USING btree (inserted_at);


--
-- Name: media_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX media_status_index ON public.media USING btree (status);


--
-- Name: media_tags_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX media_tags_index ON public.media USING gin (tags);


--
-- Name: media_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX media_user_id_index ON public.media USING btree (user_id);


--
-- Name: newsletters_sent_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX newsletters_sent_at_index ON public.newsletters USING btree (sent_at);


--
-- Name: newsletters_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX newsletters_status_index ON public.newsletters USING btree (status);


--
-- Name: newsletters_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX newsletters_user_id_index ON public.newsletters USING btree (user_id);


--
-- Name: page_sections_page_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX page_sections_page_id_index ON public.page_sections USING btree (page_id);


--
-- Name: page_sections_page_id_key_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX page_sections_page_id_key_index ON public.page_sections USING btree (page_id, key);


--
-- Name: page_sections_position_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX page_sections_position_index ON public.page_sections USING btree ("position");


--
-- Name: pages_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX pages_slug_index ON public.pages USING btree (slug);


--
-- Name: press_features_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX press_features_date_index ON public.press_features USING btree (date);


--
-- Name: press_features_position_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX press_features_position_index ON public.press_features USING btree ("position");


--
-- Name: press_features_published_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX press_features_published_index ON public.press_features USING btree (published);


--
-- Name: series_media_file_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX series_media_file_id_index ON public.series USING btree (media_file_id);


--
-- Name: series_position_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX series_position_index ON public.series USING btree ("position");


--
-- Name: series_published_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX series_published_index ON public.series USING btree (published);


--
-- Name: series_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX series_slug_index ON public.series USING btree (slug);


--
-- Name: series_title_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX series_title_index ON public.series USING btree (title);


--
-- Name: subscribers_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX subscribers_email_index ON public.subscribers USING btree (email);


--
-- Name: users_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_email_index ON public.users USING btree (email);


--
-- Name: users_tokens_context_token_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_tokens_context_token_index ON public.users_tokens USING btree (context, token);


--
-- Name: users_tokens_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_tokens_user_id_index ON public.users_tokens USING btree (user_id);


--
-- Name: artworks artworks_media_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artworks
    ADD CONSTRAINT artworks_media_file_id_fkey FOREIGN KEY (media_file_id) REFERENCES public.media(id) ON DELETE SET NULL;


--
-- Name: artworks artworks_series_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artworks
    ADD CONSTRAINT artworks_series_id_fkey FOREIGN KEY (series_id) REFERENCES public.series(id) ON DELETE SET NULL;


--
-- Name: enquiries enquiries_artwork_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enquiries
    ADD CONSTRAINT enquiries_artwork_id_fkey FOREIGN KEY (artwork_id) REFERENCES public.artworks(id) ON DELETE SET NULL;


--
-- Name: media_images media_images_artwork_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_images
    ADD CONSTRAINT media_images_artwork_id_fkey FOREIGN KEY (artwork_id) REFERENCES public.artworks(id) ON DELETE CASCADE;


--
-- Name: media_images media_images_media_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_images
    ADD CONSTRAINT media_images_media_file_id_fkey FOREIGN KEY (media_file_id) REFERENCES public.media(id) ON DELETE SET NULL;


--
-- Name: media media_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media
    ADD CONSTRAINT media_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: newsletters newsletters_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletters
    ADD CONSTRAINT newsletters_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: page_sections page_sections_page_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_sections
    ADD CONSTRAINT page_sections_page_id_fkey FOREIGN KEY (page_id) REFERENCES public.pages(id) ON DELETE CASCADE;


--
-- Name: series series_media_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.series
    ADD CONSTRAINT series_media_file_id_fkey FOREIGN KEY (media_file_id) REFERENCES public.media(id) ON DELETE SET NULL;


--
-- Name: users_tokens users_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_tokens
    ADD CONSTRAINT users_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict pnNeHZdijrgrQiwnTR40UHDLmZY9qZVUmvX9LPnTXcgQTqlJvWIcjYpO1L4rwwT

INSERT INTO public."schema_migrations" (version) VALUES (20251114204733);
INSERT INTO public."schema_migrations" (version) VALUES (20251114204951);
INSERT INTO public."schema_migrations" (version) VALUES (20251114205004);
INSERT INTO public."schema_migrations" (version) VALUES (20251114205021);
INSERT INTO public."schema_migrations" (version) VALUES (20251114205046);
INSERT INTO public."schema_migrations" (version) VALUES (20251114205047);
INSERT INTO public."schema_migrations" (version) VALUES (20251114205048);
INSERT INTO public."schema_migrations" (version) VALUES (20251114205125);
INSERT INTO public."schema_migrations" (version) VALUES (20251114205127);
INSERT INTO public."schema_migrations" (version) VALUES (20251114205128);
INSERT INTO public."schema_migrations" (version) VALUES (20251114205129);
INSERT INTO public."schema_migrations" (version) VALUES (20251114213451);
INSERT INTO public."schema_migrations" (version) VALUES (20251114214601);
INSERT INTO public."schema_migrations" (version) VALUES (20251115113433);
INSERT INTO public."schema_migrations" (version) VALUES (20251115124158);
INSERT INTO public."schema_migrations" (version) VALUES (20251115213916);

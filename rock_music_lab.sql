--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1
-- Dumped by pg_dump version 15.1

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: album; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.album (
    id integer NOT NULL,
    name character varying NOT NULL,
    songs_quantity integer NOT NULL,
    band_id integer NOT NULL,
    release_date date NOT NULL
);


ALTER TABLE public.album OWNER TO postgres;

--
-- Name: album_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.album ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.album_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: band; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.band (
    id integer NOT NULL,
    name character varying NOT NULL,
    members_quantity integer NOT NULL,
    foundation_date date NOT NULL
);


ALTER TABLE public.band OWNER TO postgres;

--
-- Name: band_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.band ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.band_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: song; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.song (
    id integer NOT NULL,
    name character varying NOT NULL,
    duration integer NOT NULL,
    album_id integer NOT NULL
);


ALTER TABLE public.song OWNER TO postgres;

--
-- Name: song_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.song ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.song_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Data for Name: album; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.album OVERRIDING SYSTEM VALUE VALUES (3, 'A Night at the Opera', 12, 2, '1975-12-02');
INSERT INTO public.album OVERRIDING SYSTEM VALUE VALUES (2, 'Californication', 15, 5, '1999-06-08');
INSERT INTO public.album OVERRIDING SYSTEM VALUE VALUES (1, 'Stadium Arcadium', 28, 5, '2006-05-09');
INSERT INTO public.album OVERRIDING SYSTEM VALUE VALUES (4, 'News of the World', 11, 2, '1977-10-28');
INSERT INTO public.album OVERRIDING SYSTEM VALUE VALUES (6, 'Love at First Sting', 14, 1, '1984-05-04');
INSERT INTO public.album OVERRIDING SYSTEM VALUE VALUES (5, 'Humanity: Hour I', 15, 1, '2007-05-14');
INSERT INTO public.album OVERRIDING SYSTEM VALUE VALUES (7, 'Ride the Lightning', 8, 3, '1984-07-27');
INSERT INTO public.album OVERRIDING SYSTEM VALUE VALUES (9, 'Led Zeppelin III', 10, 4, '1970-10-05');
INSERT INTO public.album OVERRIDING SYSTEM VALUE VALUES (10, 'Led Zeppelin IV', 8, 4, '1971-11-08');
INSERT INTO public.album OVERRIDING SYSTEM VALUE VALUES (8, 'Metallica', 12, 3, '1991-08-12');


--
-- Data for Name: band; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.band OVERRIDING SYSTEM VALUE VALUES (1, 'Scorpions', 5, '1965-06-01');
INSERT INTO public.band OVERRIDING SYSTEM VALUE VALUES (2, 'Queen', 4, '1970-06-27');
INSERT INTO public.band OVERRIDING SYSTEM VALUE VALUES (3, 'Metallica', 4, '1981-10-28');
INSERT INTO public.band OVERRIDING SYSTEM VALUE VALUES (4, 'Led Zeppelin', 4, '1968-09-15');
INSERT INTO public.band OVERRIDING SYSTEM VALUE VALUES (5, 'Red Hot Chili Peppers', 4, '1983-06-05');


--
-- Data for Name: song; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.song OVERRIDING SYSTEM VALUE VALUES (1, 'Stairway to Heaven', 482, 10);
INSERT INTO public.song OVERRIDING SYSTEM VALUE VALUES (2, 'Black Dog', 296, 10);
INSERT INTO public.song OVERRIDING SYSTEM VALUE VALUES (3, 'Immigrant Song', 143, 9);
INSERT INTO public.song OVERRIDING SYSTEM VALUE VALUES (4, 'Since I’ve Been Loving You', 444, 9);
INSERT INTO public.song OVERRIDING SYSTEM VALUE VALUES (5, 'Enter Sandman', 330, 8);
INSERT INTO public.song OVERRIDING SYSTEM VALUE VALUES (6, 'Sad But True', 323, 8);
INSERT INTO public.song OVERRIDING SYSTEM VALUE VALUES (7, 'Fade to Black', 419, 7);
INSERT INTO public.song OVERRIDING SYSTEM VALUE VALUES (8, 'For Whom the Bell Tolls', 309, 7);
INSERT INTO public.song OVERRIDING SYSTEM VALUE VALUES (9, 'Still Loving You', 386, 6);
INSERT INTO public.song OVERRIDING SYSTEM VALUE VALUES (10, 'Rock You Like a Hurricane', 252, 6);
INSERT INTO public.song OVERRIDING SYSTEM VALUE VALUES (11, 'Humanity', 326, 5);
INSERT INTO public.song OVERRIDING SYSTEM VALUE VALUES (12, 'Love Will Keep Us Alive', 272, 5);
INSERT INTO public.song OVERRIDING SYSTEM VALUE VALUES (13, 'We Will Rock You', 121, 4);
INSERT INTO public.song OVERRIDING SYSTEM VALUE VALUES (14, 'We Are the Champions', 179, 4);
INSERT INTO public.song OVERRIDING SYSTEM VALUE VALUES (15, 'Bohemian Rhapsody', 355, 3);
INSERT INTO public.song OVERRIDING SYSTEM VALUE VALUES (16, 'Love of My Life', 219, 3);
INSERT INTO public.song OVERRIDING SYSTEM VALUE VALUES (17, 'Californication', 321, 2);
INSERT INTO public.song OVERRIDING SYSTEM VALUE VALUES (18, 'Otherside', 255, 2);
INSERT INTO public.song OVERRIDING SYSTEM VALUE VALUES (19, 'Dani California', 282, 1);
INSERT INTO public.song OVERRIDING SYSTEM VALUE VALUES (20, 'Snow (Hey oh)', 335, 1);


--
-- Name: album_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.album_id_seq', 10, true);


--
-- Name: band_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.band_id_seq', 5, true);


--
-- Name: song_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.song_id_seq', 20, true);


--
-- Name: album album_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.album
    ADD CONSTRAINT album_pk PRIMARY KEY (id);


--
-- Name: band band_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.band
    ADD CONSTRAINT band_pk PRIMARY KEY (id);


--
-- Name: song song_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.song
    ADD CONSTRAINT song_pk PRIMARY KEY (id);


--
-- Name: album band_name; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.album
    ADD CONSTRAINT band_name FOREIGN KEY (band_id) REFERENCES public.band(id);


--
-- Name: song song_album_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.song
    ADD CONSTRAINT song_album_id_fk FOREIGN KEY (album_id) REFERENCES public.album(id);


--
-- PostgreSQL database dump complete
--


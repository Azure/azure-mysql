CREATE DATABASE inventory
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;
	
CREATE TABLE public.catalog
(
    id bigserial NOT NULL,
    name character varying(500) NOT NULL,
    description text,
    category character varying(100) NOT NULL,
    PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
);

ALTER TABLE public.catalog
    OWNER to postgres;

CREATE TABLE public.orders
(
    id bigserial NOT NULL,
    catalogid bigint NOT NULL,
    orderdate timestamp(2) without time zone DEFAULT now(),
    quantity bigint NOT NULL,
    PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
);

ALTER TABLE public.orders
    OWNER to postgres;
	
CREATE VIEW order_view AS SELECT o.id, c.name, o.orderdate, o.quantity FROM orders o, catalog c where o.catalogid = c.id order by id desc
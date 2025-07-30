ALTER SYSTEM SET max_connections = 500;

create table payments
(
    uuid        uuid              not null primary key,
    amount      numeric           not null,
    gateway_id  integer,
    retries     integer default 0 not null,
    inserted_at timestamp         not null,
    updated_at  timestamp         not null
);

create index payments_gateway_id_index on public.payments (gateway_id);
create index payments_inserted_at_index on public.payments (inserted_at);

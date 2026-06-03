CREATE SCHEMA sub;

CREATE TABLE sub.subscriptions
(
    id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    service_name VARCHAR(255) NOT NULL,
    price        INTEGER      NOT NULL CHECK (price >= 0),
    user_id      UUID         NOT NULL,
    start_date   DATE         NOT NULL,
    end_date     DATE,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),

    CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE INDEX subscriptions_user_id_idx ON sub.subscriptions (user_id);
CREATE INDEX subscriptions_service_name_idx ON sub.subscriptions (service_name);
CREATE INDEX subscriptions_period_idx ON sub.subscriptions (start_date, end_date);

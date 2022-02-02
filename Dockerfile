FROM python:3.10.1 as builder

WORKDIR /app
RUN pip install --upgrade pip && pip install poetry
COPY pyproject.toml poetry.lock ./
RUN poetry export --without-hashes -f requirements.txt > requirements.txt
RUN poetry export --without-hashes --dev -f requirements.txt > requirements-dev.txt
RUN apt-get update && apt-get install -y build-essential
RUN pip install -r requirements.txt

### for dev
FROM python:3.10.1-slim as dev
ENV PYTHONUNBUFFERED=1
WORKDIR /app
RUN apt-get update && apt-get install -y default-jre
COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages
COPY --from=builder /app/requirements-dev.txt requirements-dev.txt
RUN pip install -r requirements-dev.txt

COPY --from=builder /usr/local/bin/ /usr/local/bin/
COPY ./ ./
EXPOSE 8000
CMD ["python", "src/main.py"]

### for prod
FROM python:3.10.1-slim as prod
ENV PYTHONUNBUFFERED=1
WORKDIR /app
COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages

COPY --from=builder /usr/local/bin/ /usr/local/bin/
COPY ./ ./
EXPOSE 8000
CMD ["python", "src/main.py"]

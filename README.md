# pulsar-topics-configuration
A bash script to configure persistent topics with custom retention period and backlog quotas.

## Motivation:
I am using this script for configuring persisten topics for a data ingetion pipeline. I needed longer retention for a CQRS system for replaying any acknowled messages at any point in time. 
#! /bin/bash

if [ -z "$PULSAR_HOME" ];then
    PULSAR_HOME="/pulsar"
fi

export PATH=$PATH:$PULSAR_HOME/bin

TENANT="companyABC"
LOGS_NAMESPACE="data-logs"
TOPICS_NAMESPACE="data-topics"

# topics
declare -A TOPICS
TOPICS['PUBLIC_EVENTS']="persistent://$TENANT/$LOGS_NAMESPACE/public-events"
TOPICS['WORKER_EVENTS']="persistent://$TENANT/$LOGS_NAMESPACE/worker-events"
TOPICS['COMMANDS']="persistent://$TENANT/$TOPICS_NAMESPACE/commands"
TOPICS['REPLIES']="persistent://$TENANT/$TOPICS_NAMESPACE/replies"

# set unlimited retention time and size for topics
RETENTION_PERIOD=-1
RENTION_SIZE=-1

# backlog quota for un-acknowledged messages
BACKLOG_QUOTA_LIMIT="4G"
BACKLOG_QUOTA_POLICY="producer_request_hold"

################################################################## Main Section #########################################################

type pulsar-admin &> /dev/null || {
    echo "ERROR: pulsar-admin binary doesn't seem to exist in the PATH. Please set PULSAR_HOME environment variable to the correct path."
    exit 1
    }

#create tenant
echo "[!]. Creating tenant: $TENANT"
pulsar-admin tenants create $TENANT

#create namespace
echo "[!]. Creating namespace: $TENANT/$LOGS_NAMESPACE"
pulsar-admin namespaces create $TENANT/$LOGS_NAMESPACE

echo "[!]. Creating namespace: $TENANT/$TOPICS_NAMESPACE"
pulsar-admin namespaces create $TENANT/$TOPICS_NAMESPACE

#configure namespace retention policy
echo    "[!]. Configuring retention policy for namespace: $TENANT/$LOGS_NAMESPACE"
echo -e "[!]. Policy Details:\n\t\tRetention_Period: $RETENTION_PERIOD\n\t\tRetention_Size: $RENTION_SIZE"
pulsar-admin namespaces set-retention $TENANT/$LOGS_NAMESPACE --time $RETENTION_PERIOD --size $RENTION_SIZE

echo    "[!]. Configuring retention policy for namespace: $TENANT/$TOPICS_NAMESPACE"
echo -e "[!]. Policy Details:\n\t\tRetention_Period: $RETENTION_PERIOD\n\t\tRetention_Size: $RENTION_SIZE"
pulsar-admin namespaces set-retention $TENANT/$TOPICS_NAMESPACE --time $RETENTION_PERIOD --size $RENTION_SIZE

#configure backlog quota limit
echo "[!]. Setting backlog quota limit to $BACKLOG_QUOTA_LIMIT"
pulsar-admin namespaces set-backlog-quota $TENANT/$LOGS_NAMESPACE --limit $BACKLOG_QUOTA_LIMIT --policy $BACKLOG_QUOTA_POLICY

echo "[!]. Setting backlog quota limit to $BACKLOG_QUOTA_LIMIT"
pulsar-admin namespaces set-backlog-quota $TENANT/$TOPICS_NAMESPACE --limit $BACKLOG_QUOTA_LIMIT --policy $BACKLOG_QUOTA_POLICY

# create topics
for topicName in "${!TOPICS[@]}";
do
    topicUri=${TOPICS[$topicName]}
    echo "[!]. Creating '$topicName' topic with URI '$topicUri'"
    pulsar-admin topics create $topicUri
done

echo -e "[!]. Setup is done. Everything is good to go :)\n"

################################# References #################################
# Please refer the following resources for further details.
# References:
#       1- https://github.com/apache/pulsar/blob/master/faq.md#how-can-i-prevent-an-inactive-topic-to-be-deleted-under-any-circumstance-i-want-to-set-no-time-or-space-limit-for-a-certain-namespace
#       2- https://pulsar.apache.org/docs/en/cookbooks-retention-expiry/#set-retention-policy
#       3- https://pulsar.apache.org/docs/en/cookbooks-retention-expiry/#backlog-quotas
##############################################################################
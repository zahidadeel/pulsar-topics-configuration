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

type pulsar-admin &> /dev/null || {
    echo "ERROR: pulsar-admin binary doesn't seem to exist in the PATH. Please set PULSAR_HOME environment variable to the correct path."
    exit 1
    }

for topicName in "${!TOPICS[@]}";
do
    topicUri=${TOPICS[$topicName]}
    echo "[!]. Deleting '$topicName' topic with URI '$topicUri'"

    # unload a topic to avoid a deletion failure
    pulsar-admin persistent unload $topicUri 
    pulsar-admin persistent delete --force $topicUri
done

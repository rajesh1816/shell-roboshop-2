#!/bin/bash
set -e  # exit immediately if any command fails

# ---- Configurable Variables ----
AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0256c6a54027858fd"     # replace with your Security Group ID
ZONE_ID="Z00035852NN6D25PW7BUM"  # replace with your Hosted Zone ID
DOMAIN_NAME="rajeshit.space"     # replace with your domain
INSTANCE_TYPE="t3.micro"

# ---- Input Arguments ----
INSTANCES=("$@")

# Check if any instances are provided
if [ ${#INSTANCES[@]} -eq 0 ]; then
    echo "❌ No instances provided. Usage: ./create-ec2.sh frontend backend db"
    exit 1
fi

# ---- Loop Through All Instances ----
for instance in "${INSTANCES[@]}"; do
    echo "🚀 Launching instance: $instance"

    # Create instance and get ID
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id "$AMI_ID" \
        --instance-type "$INSTANCE_TYPE" \
        --security-group-ids "$SG_ID" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
        --query "Instances[0].InstanceId" \
        --output text)

    echo "✅ Instance created with ID: $INSTANCE_ID"

    # Wait for instance to be running
    echo "⏳ Waiting for $instance to enter 'running' state..."
    aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

    # Fetch the IP based on condition
    if [[ "$instance" == "frontend" ]]; then
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query "Reservations[0].Instances[0].PublicIpAddress" \
            --output text)
        RECORD_NAME="$DOMAIN_NAME"
    else
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query "Reservations[0].Instances[0].PrivateIpAddress" \
            --output text)
        RECORD_NAME="$instance.$DOMAIN_NAME"
    fi

    echo "🔹 $instance IP: $IP"

    # ---- Update DNS Record ----
    echo "🛠️ Updating DNS record: $RECORD_NAME -> $IP"

    aws route53 change-resource-record-sets \
        --hosted-zone-id "$ZONE_ID" \
        --change-batch "{
            \"Comment\": \"Creating or Updating record for $instance\",
            \"Changes\": [{
                \"Action\": \"UPSERT\",
                \"ResourceRecordSet\": {
                    \"Name\": \"$RECORD_NAME\",
                    \"Type\": \"A\",
                    \"TTL\": 1,
                    \"ResourceRecords\": [{\"Value\": \"$IP\"}]
                }
            }]
        }"

    echo "✅ DNS record updated: $RECORD_NAME -> $IP"
    echo "--------------------------------------------"
done

echo "🎉 All instances created and DNS records updated successfully!"

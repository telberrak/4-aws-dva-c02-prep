## Step 1: Launch an EC2 Instance
    #Log in to the AWS Management Console.
    #Launch an EC2 instance (e.g., Amazon Linux 2 or Ubuntu).
    #Ensure the security group allows inbound traffic on ports 9092 (Kafka broker) and 9093 (KRaft controller).
    #SSH into the instance.

##Step 2: Install Java

sudo dnf install java-17-amazon-corretto-devel -y
sudo update-alternatives --config java
sudo echo "export JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto.x86_64" >> ~/.bashrc
source ~/.bashrc

## Step 3: Download and Extract Kafka

sudo wget https://dlcdn.apache.org/kafka/4.0.0/kafka_2.13-4.0.0.tgz
sudo tar -xzf kafka_2.13-4.0.0.tgz
sudo mv kafka_2.13-4.0.0 /opt/kafka


## Step 4: Configure Kafka in KRaft Mode

    #1. Generate a cluster UUID:

sudo /opt/kafka/bin/kafka-storage.sh random-uuid

    #2. Format the storage directory:

sudo mkdir -p /opt/kafka/config/kraft

sudo cp /opt/kafka/config/kraft/server.properties /opt/kafka/config/kraft

sudo /opt/kafka/bin/kafka-storage.sh format -t rpe0BswgSia73m567E3QgA -c /opt/kafka/config/kraft/server.properties

    #3. Edit the server.properties file for KRaft mode:

    sudo vi /opt/kafka/config/kraft/server.properties

    node.id=1
    process.roles=broker,controller
    listeners=PLAINTEXT://:9092,CONTROLLER://:9093
    advertised.listeners=PLAINTEXT://localhost:9092
    controller.quorum.voters=1@localhost:9093
    log.dirs=/opt/kafka/logs

    #Save and exit.

## Step 5: Start the Kafka Broker

channge memory in server.properties
    sudo sed -i 's/-Xmx1G/-Xmx512M/g' /opt/kafka/config/kraft/server.properties
    sudo sed -i 's/-Xms1G/-Xms512M/g' /opt/kafka/config/kraft/server.properties

    #Start the Kafka broker in KRaft mode:

sudo /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/kraft/server.properties

#Kafka should now be running in KRaft mode on localhost:9092.

## Step 6: Test the Setup

    #1. Create a topic:

    sudo /opt/kafka/bin/kafka-topics.sh --create --topic drones-stream --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1

    #2. Produce a message:

    sudo /opt/kafka/bin/kafka-console-producer.sh --topic drones-stream --bootstrap-server localhost:9092

    #3. Consume the message:

    sudo /opt/kafka/bin/kafka-console-consumer.sh --topic drones-stream --bootstrap-server localhost:9092 --from-beginning



curl -X POST -H "Content-Type: text/plain" -u kafka:kafka -d "Hello Kafka" http://localhost:8083/kafka/send
## Step 7: Add EC2 Instance to an Auto Scaling Group

    #1 Create an Amazon Machine Image (AMI) of the EC2 instance:  
        #Log in to the AWS Management Console.
        #Navigate to the EC2 dashboard.
        #Select the instance and click Actions > Image and templates > Create image.
        #Enter a name and description for the image, then click Create image.
        #Wait for the image creation to complete.
    #2 Create a Launch Template:
        #Navigate to the EC2 dashboard.
        #Click Launch Templates in the left sidebar.
        #Click Create launch template.
        #Enter a name and description for the launch template.
        #Select the AMI created in step 1.
        #Configure the instance type, security group, key pair, and other settings as needed.
        #Click Create launch template.
    #3 Create an Auto Scaling Group:
        #Navigate to the EC2 dashboard.
        #Click Auto Scaling Groups in the left sidebar.
        #Click Create Auto Scaling group.
        #Select the launch template created in step 2.
        #Configure the desired capacity, scaling policies, and other settings as needed.
        #Click Create Auto Scaling group.
    #4 Monitor the Auto Scaling Group:
        #Navigate to the EC2 dashboard.
        #Click Auto Scaling Groups in the left sidebar.
        #Select the auto scaling group created in step 3.
        #Monitor the instances and scaling activities in the group.

## Step 8: Automate Kafka Startup
    #To ensure Kafka starts automatically on instance launch:

    #1. Create a systemd service file:

    sudo nano /etc/systemd/system/kafka.service

    #2. Add the following content:
    [Unit]
    Description=Apache Kafka Server
    After=network.target

    [Service]
    User=ec2-user
    ExecStart=/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/kraft/server.properties
    ExecStop=/opt/kafka/bin/kafka-server-stop.sh
    Restart=on-failure

    [Install]
    WantedBy=multi-user.target

    #Save and exit.

    #3. Enable and start the Kafka service:

    sudo systemctl enable kafka
    sudo systemctl start kafka

## Step 9: Test Auto Scaling
    #To test the auto scaling setup:

    #1. Monitor the auto scaling group in the AWS Management Console.
    #2. Manually terminate an instance to trigger auto scaling.
    #3. Verify that a new instance is launched and Kafka is running on the new instance.

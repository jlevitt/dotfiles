send-msg() {
    sudo rabbitmqadmin -u admin -p admin -V tasks publish exchange=$1 routing_key=''
}

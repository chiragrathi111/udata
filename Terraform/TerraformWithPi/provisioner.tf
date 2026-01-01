provisioner "remote-exec" {
    inline = [
        "sudo apt update",
        "sudo apt install -y mysql-server",
        "sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf",
        "sudo systemctl restart mysql",
        "sudo 'my new file ! testing' | sudo tee /tem/test/txt"
    ]
}

# this provisioner will create a file on the ec2 instance without login ec2 file is created 
# means if you miss user data so this file added and updated so few softwere and file install and created if you need according


# if you want send file local to server so below code using

provisioner "file" {
    source = "${path.module}/hello.txt"
    destination = "/tmp/hello.txt"
    connection {
        type = "ssh"
        user = "ubuntu"
        private_key = "${file("terraform.pem")}"
        timeout = "2m"
        host = "${aws_instance.ec2.public_ip}" #${self.public_ip}
    }
}
  #!/bin/bash
  sudo yum update -y
  sudo yum install -y httpd 
  sudo systemctl start httpd
  sudo systemctl enable httpd
  echo "Welcome to ${env}" > /var/www/html/index.html
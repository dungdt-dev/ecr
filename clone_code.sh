# Nhận giá trị AWS_ACCESS_KEY_ID từ tham số dòng lệnh
AWS_ACCESS_KEY_ID="$1"

# Sử dụng giá trị biến môi trường
echo "AWS_ACCESS_KEY_ID from Jenkins : $AWS_ACCESS_KEY_ID"

if [ -d "ecr" ]; then
    cd ecr
    git pull
else
    git clone https://github.com/dungdt-dev/ecr.git
fi

set -x

new_dir=/root/win_ssl
Email=""

key_loc="$new_dir"/keys
csr_loc="$new_dir"/csr

mkdir -p "$key_loc" "$csr_loc"

if [[ -f "$new_dir"/openssl-san.cnf ]] && [[ -f "$new_dir"/hosts ]]
then
        for host in `cat "$new_dir"/hosts | egrep -v '^#|^$'`;
        do
                hostname=$(echo $host | awk -F'.' '{print $1}')
                cat "$new_dir"/openssl-san.cnf | sed "s+DNS.1  =+DNS.1   = $host+g" >> "$new_dir"/"$hostname"-san.cnf
                openssl genrsa -out "$key_loc"/"$hostname"_PrivateKey.key 2048
                openssl req -new -config "$new_dir"/"$hostname"-san.cnf -out "$csr_loc"/"$hostname"_new.CSR -key "$key_loc"/"$hostname"_PrivateKey.key -subj "/CN="$host"/emailAddress=$Email"
                rm "$new_dir"/"$hostname"-san.cnf
        done
else
        echo "openssl or hosts file is missing"
fi

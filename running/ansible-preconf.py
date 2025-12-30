import subprocess
import os
import pwd
import grp
from pathlib import Path
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import ed25519


class Prerequisite:

    def __init__(self, ansible_user="ansible", key_name="id_ansible", gid="10000", uid="10000"):
        self.ansible_user = ansible_user
        self.key_name = key_name
        self.__ansible_user_group = ansible_user
        self.gid = gid
        self.uid = uid

    def ensure_user_and_groups_exists(self):
        print("1.Ensure user and groups exists on the system")
        try:
            grp.getgrnam(self.__ansible_user_group)
            print("   Group exists")
        except KeyError:
            print("   Group does not exist, I will create them.")
            self.create_group()

        try:
            pwd.getpwnam(self.ansible_user)
            print("   User exists")
        except KeyError:
            print("   User does not exist, I will create them.")
            self.create_user()
        
    def _explicitly_lock_password(self):
        try:
            subprocess.run(["sudo", "passwd","-l", self.ansible_user], check=True, capture_output=True, text=True)
        except subprocess.CalledProcessError as error:
            error_msg = error.stderr.strip()
            return False, error_msg        

    def create_user(self):
        print("3. Creating users...")
        try:
            subprocess.run(["useradd","-u",self.uid,"-g",self.gid, "-G", "sudo", "-m", "-s","/bin/bash", self.ansible_user], check=True, capture_output=True, text=True)
            self._explicitly_lock_password()
            self._password_less_sudo()
        except subprocess.CalledProcessError as error:
            error_msg = error.stderr.strip()
            return False, error_msg

        
    def create_group(self):
        print("2. Creating groups...")
        try:
            subprocess.run(["groupadd", "-g", self.gid,self.__ansible_user_group], check=True, capture_output=True, text=True)
        except subprocess.CalledProcessError as error:
            error_msg = error.stderr.strip()
            return False, error_msg
    
    def _password_less_sudo(self):
        path_for_sudoers= Path(f"/etc/sudoers.d/{self.ansible_user}")
        content_file = f"{self.ansible_user} ALL=(ALL) NOPASSWD: ALL\n"

        try:
            with open(path_for_sudoers, "w") as file:
                file.write(content_file)
            os.chmod(path_for_sudoers, 0o440)
        except PermissionError as permission:
            print(f"You do not have privileges to the {path_for_sudoers}, rerun the script with administrator privileges")
            return False
        
        check = subprocess.run(["sudo", "visudo", "-cf", path_for_sudoers], capture_output=True, text=True, check=True)
        if check.returncode == 0:
            return True
        else:
            os.remove(path_for_sudoers)
            return False

    def check_env_and_create_ssh_dir(self):
        self.path_for_ssh_dir = Path(f"/home/{self.ansible_user}/.ssh")
        path_for_home_user = Path(f"/home/{self.ansible_user}")
        
        try:
            os.listdir(path_for_home_user)
            if not os.path.exists(self.path_for_ssh_dir):
                os.mkdir(self.path_for_ssh_dir)
                os.chmod(self.path_for_ssh_dir, 0o600)
            return self.path_for_ssh_dir
        except FileNotFoundError:
           print(f"Home path for user: {self.ansible_user} doesn't exist.")
           return False


class ServerSide(Prerequisite):

    def __init__(self, key_name="id_ansible", key_passphrase: str | None = None):
        self.key_name = key_name
        self.key_passphrase = key_passphrase
        super().__init__()

    def create_ssh_dir(self):
        return self.check_env_and_create_ssh_dir()

    def create_ssh_key(self):
        private_key = ed25519.Ed25519PrivateKey.generate()
        encryption = (serialization.BestAvailableEncryption(self.key_passphrase) if self.key_passphrase else serialization.NoEncryption())

        self.full_path_for_private_key = Path(f"{self.path_for_ssh_dir}/{self.key_name}")
        self.full_path_for_public_key = Path(f"{self.path_for_ssh_dir}/{self.key_name}.pub")


        public_key = private_key.public_key()

        with open(self.full_path_for_private_key, "wb") as private_key_file:
            private_key_file.write(private_key.private_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PrivateFormat.OpenSSH,
                encryption_algorithm=encryption
            ))
        
        with open(self.full_path_for_public_key, "wb") as public_key_file:
            public_key_file.write(public_key.public_bytes(
                encoding=serialization.Encoding.OpenSSH,
                format=serialization.PublicFormat.OpenSSH
            ))
        
        for file in  self.path_for_ssh_dir.iterdir():
            os.chmod(file, 0o600)
        
        self.shared_pub_key_for_admin_user()


    def shared_pub_key_for_admin_user(self):
        _create_dir_for_ssh_keys = subprocess.run([ 
            "install",
            "-d",
            "-o", "admin",
            "-g", "admin",
            "-m", "0755",
            "/home/admin/ansible_keys"
            ],capture_output=True, text=True, check=True)
        
        if _create_dir_for_ssh_keys.returncode == 0:         
            _public_key = subprocess.run([         
            "install",
            "-o", "admin",
            "-g", "admin",
            "-m", "0600",
            f"{self.full_path_for_public_key}",
            f"/home/admin/ansible_keys/{self.key_name}.pub"],capture_output=True, text=True, check=True)
            _private_key = subprocess.run([         
            "install",
            "-o", "admin",
            "-g", "admin",
            "-m", "0600",
            f"{self.full_path_for_private_key}",
            f"/home/admin/ansible_keys/{self.key_name}"],capture_output=True, text=True, check=True)
            if not (_public_key.returncode == 0 and _private_key.returncode == 0):
                print("Error while configuration ssh keys for user admin")
                return False
                




def main():    

    if os.getuid() == 0:
        request = ServerSide()
        request.ensure_user_and_groups_exists()
        request.create_ssh_dir()
        request.create_ssh_key()
    else:
        print("Please rerun with an administrator privlieges")


if __name__ == "__main__":
    main()
resource "null_resource" "example" {
provisioner "local-exec" {
    command = "ansible-playbook mysqlCluster.yml"
}
}

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}
provider "yandex" {
    zone      = "ru-central1-a"
}
resource "yandex_mdb_postgresql_cluster" "postgresql-baryshnikov" {
  name                = "postgresql-baryshnikov"
  environment         = "PRODUCTION"
  network_id          = yandex_vpc_network.network-1.id
  security_group_ids  = [ yandex_vpc_security_group.pgsql-sg.id ]
  deletion_protection = false

  config {
    version = 15
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-ssd"
      disk_size          = "10"
    }
  }

  host {
    zone      = "ru-central1-a"
    name      = "rc1a-bpvf5luagjcamekd"
    subnet_id = yandex_vpc_subnet.subnet-1.id
    assign_public_ip = true
  }
  host {
    zone      = "ru-central1-b"
    name      = "rc1b-r5lgphltb5y7gxwb"
    subnet_id = yandex_vpc_subnet.subnet-2.id
    assign_public_ip = true
  }  
}
resource "yandex_vpc_network" "network-1" {
  name = "network1"
}
resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}
resource "yandex_vpc_subnet" "subnet-2" {
  name           = "subnet2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.11.0/24"]
}
resource "yandex_vpc_security_group" "pgsql-sg" {
  name       = "pgsql-sg"
  network_id = yandex_vpc_network.network-1.id

  ingress {
    description    = "PostgreSQL"
    port           = 6432
    protocol       = "TCP"
    v4_cidr_blocks = [ "0.0.0.0/0" ]
  }
}
resource "yandex_mdb_postgresql_database" "db1_baryshnikov" {
  cluster_id = yandex_mdb_postgresql_cluster.postgresql-baryshnikov.id
  name       = "db1_baryshnikov"
  owner      = "baryshnikov"
}
resource "yandex_mdb_postgresql_user" "baryshnikov" {
  cluster_id = yandex_mdb_postgresql_cluster.postgresql-baryshnikov.id
  name       = "baryshnikov"
  password   = "123456789"
}
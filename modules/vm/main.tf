resource "proxmox_virtual_environment_vm" "this" {
  node_name = "pve"
  vm_id     = var.id

  name            = "${var.name}.lab53.net"
  keyboard_layout = "en-us"

  machine = var.machine_type
  on_boot = var.start_on_boot

  dynamic "agent" {
    for_each = var.agent_enabled ? [1] : []

    content {
      enabled = true
    }
  }

  dynamic "clone" {
    for_each = var.clone.enabled ? [1] : []

    content {
      vm_id = var.clone.base_vm_id
    }
  }

  cpu {
    cores = var.cpu_cores
    type  = "host"
  }

  disk {
    interface = "scsi0"
    size      = var.disk_size
  }

  dynamic "initialization" {
    for_each = var.cloud_init.enabled ? [1] : []

    content {
      ip_config {
        ipv4 {
          address = "dhcp"
        }
      }

      user_account {
        keys     = var.cloud_init.keys
        username = var.cloud_init.username
        password = var.cloud_init.password
      }
    }
  }

  dynamic "hostpci" {
    for_each = var.pci_mappings

    content {
      device  = hostpci.key
      mapping = hostpci.value["mapping"]
      pcie    = hostpci.value["pcie"]
    }
  }

  memory {
    dedicated = 1024 * var.memory
  }

  network_device {
    enabled = true
    bridge  = "vmbr0"
  }

  operating_system {
    type = var.os_type
  }

  vga {
    type = "std"
  }
}
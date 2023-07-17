resource "libvirt_ignition" "ignition" {
  for_each = toset(var.machines)
  name     = "${var.cluster_name}-${each.key}-ignition"
  pool     = libvirt_pool.volumetmp.name
  content  = data.ct_config.vm-ignitions[each.key].rendered
}

data "ct_config" "vm-ignitions" {
  for_each = toset(var.machines)
  content  = data.template_file.vm-configs[each.key].rendered
}

data "template_file" "vm-configs" {
  for_each = toset(var.machines)
  template = file("${path.module}/butane-flatcar-${each.key}.yaml.tmpl")

  vars = {
    ssh_keys = jsonencode(var.ssh_keys)
    name     = each.key
  }
}

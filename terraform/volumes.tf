resource "libvirt_pool" "volumetmp" {
  name = "${var.cluster_name}-pool"
  type = "dir"
  path = "/var/tmp/${var.cluster_name}-pool"
}

resource "libvirt_volume" "base" {
  name   = "flatcar-base"
  source = var.base_image
  pool   = libvirt_pool.volumetmp.name
  format = "qcow2"
}

resource "libvirt_volume" "vm-disk" {
  for_each = toset(var.machines)
  # workaround: depend on libvirt_ignition.ignition[each.key], otherwise the VM will use the old disk when the user-data changes
  name           = "${var.cluster_name}-${each.key}-${md5(libvirt_ignition.ignition[each.key].id)}.qcow2"
  base_volume_id = libvirt_volume.base.id
  pool           = libvirt_pool.volumetmp.name
  format         = "qcow2"
}

# resource "libvirt_pool" "boot" {
#   name = "boot"
#   type = "dir"
#   path = "/var/lib/libvirt/boot"
# }

# resource "libvirt_pool" "images" {
#   name = "images"
#   type = "dir"
#   path = "/var/lib/libvirt/images"
# }

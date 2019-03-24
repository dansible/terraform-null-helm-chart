# Render install script
######################################################################
data "template_file" "chart-install-script" {
  template = "${file("${path.module}/scripts/chart_vars.sh")}"

  vars {
    kubeconfig        = "${var.kubeconfig}"
    name              = "${var.name}"
    chart_name        = "${var.chart_name}"
    chart_version     = "${var.chart_version}"
    namespace         = "${var.namespace}"
    requests-cpu      = "${var.resources["requests-cpu"]}"
    requests-memory   = "${var.resources["requests-memory"]}"
    limits-cpu        = "${var.resources["limits-cpu"]}"
    limits-memory     = "${var.resources["limits-memory"]}"
    values            = "${var.values}"
    helm-extra-args   = "${var.helm-extra-args}"
    pre-install-cmds  = "${var.pre-install-cmds}"
    post-install-cmds = "${var.post-install-cmds}"

    # Use a separate file for bash script
    logic = "${file("${path.module}/scripts/chart_logic.sh")}"
  }
}

# Render destroy script
######################################################################
data "template_file" "chart-destroy-script" {
  template = "${file("${path.module}/scripts/chart_destroy.sh")}"

  vars {
    kubeconfig        = "${var.kubeconfig}"
    name              = "${var.name}"
    pre-destroy-cmds  = "${var.pre-destroy-cmds}"
    post-destroy-cmds = "${var.post-destroy-cmds}"
  }
}

# Install Chart
######################################################################
resource "null_resource" "chart-install" {
  count = "${var.enabled}"

  triggers = {
    # Trigger deployment on script changes (destroy script does not need to trigger new deployment)
    chart_vars_change   = "${sha1(file("${path.module}/scripts/chart_vars.sh"))}"
    chart_logic_changes = "${sha1(file("${path.module}/scripts/chart_logic.sh"))}"
    vars_change = "${join(",", "${list(
      "${var.name}",
      "${var.chart_name}",
      "${var.chart_version}",
      "${var.namespace}",
      "${var.helm-extra-args}",
      "${var.pre-install-cmds}",
      "${var.post-install-cmds}",
      "${var.resources["requests-cpu"]}",
      "${var.resources["requests-memory"]}",
      "${var.resources["limits-cpu"]}",
      "${var.resources["limits-memory"]}"
    )}")}"
  }

  lifecycle = {
    create_before_destroy = true
  }

  provisioner "local-exec" {
    command     = "${data.template_file.chart-install-script.rendered}"
    interpreter = ["/usr/bin/env", "bash", "-c"]
  }
}

# Delete Chart
######################################################################
resource "null_resource" "chart-destroy" {
  count      = "${var.enabled ? 0 : 1 }"
  depends_on = ["null_resource.chart-install"]

  triggers = {
    vars_change = "${join(",", "${list(
      "${var.name}",
      "${var.chart_name}",
      "${var.namespace}"
    )}")}"
  }

  provisioner "local-exec" {
    command     = "${data.template_file.chart-destroy-script.rendered}"
    interpreter = ["/usr/bin/env", "bash", "-c"]
  }
}

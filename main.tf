
#-----------------Docker Image Build And Container Run -------------------------------

resource "docker_image" "build_image" {
  #count = local.image_count
  name = "${var.image_name}:${local.image_count}"

  build {
    context    = "."
    dockerfile = "Dockerfile"
    build_args = {
      TAG = local.image_count
    }
  }
  lifecycle {
    create_before_destroy = true
  }

}

resource "null_resource" "image_counter" {
  triggers = {
    # Every time this string changes, the resource will be recreated
    count = local.image_count
  }

  provisioner "local-exec" {
    command = "echo $(( ${local.image_count} + 1 )) > image_count.txt "
  }


  provisioner "local-exec" {
    command = "docker login -u ${var.dockerhub_username} -p ${var.dockerhub_password}"
  }
  provisioner "local-exec" {
    command = "docker images && docker push ${docker_image.build_image.name}"
  }

}



#-------------------- LOCAL------!

locals {
  image_count = try(tonumber(file("image_count.txt")), "${var.number}")
}


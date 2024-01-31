
job "redis" {
  region ="global"
  datacenters = ["dc1"]
  type = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "regexp"
    value     = "nomad-cluster-general-client-[0-9]+$"
  }

  update {
    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "3m"
    auto_revert = false
    canary = 0
  }

  group "cache" {
    count = 1
    network {
        port "redis" {
            to = 6379
        }
    }

    restart {
      # The number of attempts to run the job within the specified interval.
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    
    ephemeral_disk {
      size = 300
    }

   
    task "redis" {
      
      driver = "docker"

      config {
        image = "redis:3.2"
        ports = ["redis"]
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB
      }

      service {
        name = "redis"
        tags = []
        port = "redis"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}

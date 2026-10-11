variable "student_id" {
  description = "Identyfikator studenta: g<grupa>k<podgrupa>n<6 ostatnich cyfr indeksu>, np. g14k01n123456"
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^g[0-9]{1,2}k[0-9]{2}n[0-9]{6}$", var.student_id))
    error_message = "Format: g<grupa>k<podgrupa>n<6 ostatnich cyfr indeksu>, np. g14k01n123456."
  }
}

variable "lab" {
  description = "Numer laboratorium, trzy cyfry, np. 005"
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[0-9]{3}$", var.lab))
    error_message = "lab: trzy cyfry, np. 005."
  }
}

variable "workload" {
  description = "Obciążenie w kebab-case (małe litery, cyfry, pojedyncze '-'), np. events, event-grid"
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-z][a-z0-9]*(-[a-z0-9]+)*$", var.workload))
    error_message = "workload: kebab-case -- małe litery, cyfry, pojedyncze '-', np. event-grid."
  }
}

variable "workload_short" {
  description = "Skrót obciążenia, używany tylko w nazwach, w których pełny workload przekracza limit"
  type        = string
  default     = null

  validation {
    condition     = var.workload_short == null || can(regex("^[a-z][a-z0-9]*(-[a-z0-9]+)*$", var.workload_short))
    error_message = "workload_short: kebab-case -- małe litery, cyfry, pojedyncze '-', np. evgr."
  }
}

variable "year" {
  description = "Rok rozpoczęcia edycji kursu (tag year, klucz stanu); w nazwach dwie ostatnie cyfry"
  type        = string
  default     = "2026"

  validation {
    condition     = can(regex("^20[0-9]{2}$", var.year))
    error_message = "year: cztery cyfry, np. 2026."
  }
}

output "year" {
  description = "Rok edycji kursu, np. 2026 (tag year, klucz stanu)"
  value       = local.year
}

output "yy" {
  description = "Rok w nazwach zasobów, np. 26"
  value       = local.yy
}

output "wl" {
  description = "Obciążenie zasobów labu, np. lab005"
  value       = local.wl
}

output "tags" {
  description = "Tagi wspólne: course, year, lab, student"
  value       = local.tags
}

output "rg" {
  description = "Nazwy grup zasobów"
  value       = local.rg
}

output "common" {
  description = "Nazwy zasobów wspólnych z lab 2"
  value       = local.common
}

output "names" {
  description = "Nazwy zasobów danego laboratorium"
  value       = local.names

  # Twardy błąd zamiast cichego obcinania: za długa nazwa przerywa `tofu plan`
  precondition {
    condition     = alltrue([for k, s in local.name_spec : length(local.names[k]) <= s.max])
    error_message = "Nazwa przekracza limit: ${join(", ", [for k, s in local.name_spec : "${local.names[k]} (${length(local.names[k])}/${s.max})" if length(local.names[k]) > s.max])} -- podaj krótszy workload_short."
  }
}

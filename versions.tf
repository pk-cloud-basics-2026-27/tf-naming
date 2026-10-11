# Moduł bez providerów i zasobów -- wyłącznie obliczenia (zmienne -> locals -> outputs).
# OpenTofu >= 1.10 obsługuje źródła oci://, kurs wymaga ~> 1.12.
terraform {
  required_version = "~> 1.12"
}

# Testy konwencji nazw: tofu test (bez providerów i bez logowania do Azure)

variables {
  student_id = "g14k01n123456"
  lab        = "005"
}

run "pelna_nazwa_miesci_sie" {
  command = plan
  variables {
    workload = "ai"
  }
  assert {
    condition     = output.names.st == "stai26g14k01n123456" && output.names.kv == "kv-ai26-g14k01n123456"
    error_message = "Niepoprawne nazwy dla workload=ai: ${jsonencode(output.names)}"
  }
  assert {
    condition     = output.rg.function == "rg-labs-function-26" && output.common.gallery == "gal_labs_26"
    error_message = "Niepoprawne nazwy RG lub galerii."
  }
  assert {
    condition     = output.tags.year == "2026" && output.yy == "26"
    error_message = "Niepoprawny rok."
  }
}

run "skrot_tylko_tam_gdzie_trzeba" {
  command = plan
  variables {
    workload       = "events"
    workload_short = "evt"
  }
  assert {
    condition     = output.names.st == "stevents26g14k01n123456" # 23 znaki -- pełna nazwa
    error_message = "SA powinno użyć pełnego workload: ${output.names.st}"
  }
  assert {
    condition     = output.names.kv == "kv-evt26-g14k01n123456" # pełna miałaby 25 znaków
    error_message = "KV powinien użyć skrótu: ${output.names.kv}"
  }
}

run "kebab_case_w_stylach" {
  command = plan
  variables {
    workload       = "event-grid"
    workload_short = "ev-gr"
  }
  assert {
    condition     = output.names.st == "stevgr26g14k01n123456" # compact: bez '-'
    error_message = "SA: ${output.names.st}"
  }
  assert {
    condition     = output.names.kv == "kv-ev-gr26-g14k01n123456" # kebab: z '-'
    error_message = "KV: ${output.names.kv}"
  }
}

run "za_dluga_nazwa_bez_skrotu_to_blad" {
  command = plan
  variables {
    workload = "events"
  }
  expect_failures = [output.names]
}

run "workload_nie_w_kebab_case_to_blad" {
  command = plan
  variables {
    workload = "Event_Grid"
  }
  expect_failures = [var.workload]
}

# Konwencja nazw kursu (uproszczony CAF): <typ>-<obciążenie>-<YY>[-<student_id>]
# Ta sama logika co naming.tf w repozytoriach laboratoriów. Opis: README.md.
locals {
  course = "pk-cloud-basics"
  year   = var.year
  yy     = substr(var.year, 2, 2) # "26" -- rok w nazwach zasobów
  sid    = var.student_id
  wl     = "lab${var.lab}" # obciążenie zasobów labu, np. vm-lab007-26

  tags = {
    course  = local.course
    year    = local.year
    lab     = var.lab
    student = local.sid
  }

  # Grupy zasobów -- wspólne dla kilku labów, tworzone w lab 2
  rg = {
    common     = "rg-common-${local.yy}"
    basic      = "rg-labs-basic-${local.yy}"
    function   = "rg-labs-function-${local.yy}"
    vm         = "rg-labs-vm-${local.yy}"
    advanced   = "rg-labs-advanced-${local.yy}"
    industry40 = "rg-labs-industry40-${local.yy}"
  }

  # Zasoby wspólne z lab 2 (nazwy stałe)
  common = {
    kv      = "kv-main${local.yy}-${local.sid}"
    st_tfs  = "sttfstate${local.yy}${local.sid}"
    vnet    = "vnet-common-${local.yy}"
    cr      = "crcommon${local.yy}${local.sid}"
    id_pull = "id-acrpull-${local.yy}"
    gallery = "gal_labs_${local.yy}" # snake_case: galeria nie dopuszcza '-'
    log     = "log-common-${local.yy}"
  }

  # Nazwy zależne od workload: prefiks, separator przed student_id, limit i styl typu
  name_spec = {
    st = { prefix = "st", sep = "", max = 24, style = "compact" } # Storage Account: [a-z0-9]{3,24}
    kv = { prefix = "kv-", sep = "-", max = 24, style = "kebab" } # Key Vault: [a-z0-9-]{3,24}
  }

  # Warianty workload: pełny i skrót (domyślnie = pełny), każdy w trzech stylach
  workload_styles = {
    for v, w in { full = var.workload, short = coalesce(var.workload_short, var.workload) } :
    v => { kebab = w, snake = replace(w, "-", "_"), compact = replace(w, "-", "") }
  }

  # Kandydaci: pełna nazwa i nazwa ze skrótem
  name_candidates = {
    for k, s in local.name_spec : k => {
      for v, st in local.workload_styles : v => "${s.prefix}${st[s.style]}${local.yy}${s.sep}${local.sid}"
    }
  }

  # Pełna nazwa, jeśli się mieści, inaczej skrót -- bez obcinania (limit kontroluje output names)
  names = merge(
    {
      for k, c in local.name_candidates :
      k => length(c.full) <= local.name_spec[k].max ? c.full : c.short
    },
    {
      func = "func-${local.wl}-${local.yy}-${local.sid}" # limit 60
      plan = "asp-${local.wl}-${local.yy}"
      appi = "appi-${local.wl}-${local.yy}"
    }
  )
}

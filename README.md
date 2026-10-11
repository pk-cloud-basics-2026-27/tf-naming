# tf-naming -- konwencja nazw zasobów kursu

Moduł OpenTofu bez zasobów i providerów: na podstawie `student_id`, numeru labu i nazwy
obciążenia zwraca nazwy zasobów zgodne z konwencją kursu oraz wspólne tagi. Publikowany jako
artefakt OCI w GitHub Container Registry. Ta sama logika jest w pliku `naming.tf`
repozytoriów laboratoriów -- zmiany wprowadzamy w obu miejscach.

## Użycie

```hcl
module "naming" {
  source = "oci://ghcr.io/pk-cloud-basics-2026-27/tf-naming?tag=v1.0.0"

  student_id     = var.student_id # g14k01n123456
  lab            = "005"
  workload       = "events"
  workload_short = "evt"          # opcjonalny -- tylko gdy pełna nazwa przekracza limit
}

# module.naming.rg.function -> rg-labs-function-26
# module.naming.names.st    -> stevents26g14k01n123456   (pełny workload mieści się)
# module.naming.names.kv    -> kv-evt26-g14k01n123456    (pełny miałby 25/24 znaków)
```

Wymagania: OpenTofu `~> 1.12` (źródła `oci://` od 1.10). Pakiet jest publiczny -- `tofu init`
nie wymaga logowania.

## Konwencja nazw

Wzorzec -- uproszczony Microsoft Cloud Adoption Framework (CAF):

```text
<typ>-<obciążenie>-<YY>[-<student_id>]
```

| Element        | Opis                                                                            | Przykład           |
|----------------|---------------------------------------------------------------------------------|--------------------|
| `<typ>`        | skrót typu zasobu wg CAF                                                        | `rg`, `st`, `kv`   |
| `<obciążenie>` | grupa zasobów (`labs-vm`), zasób wspólny (`common`) lub `lab<NNN>` / `workload` | `lab005`, `events` |
| `<YY>`         | dwie ostatnie cyfry roku edycji kursu                                           | `26`               |
| `student_id`   | tylko w nazwach globalnie unikalnych (DNS)                                      | `g14k01n123456`    |

Zasady:

1. **Rok.** W nazwach zasobów zawsze `YY` (`26`). Pełny rok (`2026`) w tagu `year` i w kluczu
   stanu (`2026/<projekt>/terraform.tfstate`). Rok odróżnia zasoby kolejnych edycji kursu.
2. **`student_id`** tylko tam, gdzie nazwa jest częścią publicznej nazwy DNS (Storage Account,
   Key Vault, ACR, Function App, IoT Hub). Pozostałe nazwy są unikalne w subskrypcji studenta.
3. **Zasoby podrzędne** (podsieci, subskrypcje zdarzeń, definicje obrazów) -- bez roku
   i `student_id`; unikalność zapewnia zasób nadrzędny (`snet-labs-a` w `vnet-common-26`).
4. **Ustawienia diagnostyczne:** `diag-<nazwa zasobu>`, np. `diag-lbe-lab009-26`.
5. **Styl** wynika ze znaków dozwolonych dla typu zasobu. `workload` podajemy w kebab-case,
   moduł sam wylicza wariant (przykład: `workload = "event-grid"`, `workload_short = "ev-gr"`):

   | Styl       | Kiedy                           | Przykład                              |
   |------------|---------------------------------|---------------------------------------|
   | kebab-case | domyślnie (dozwolony `-`)       | `rg-labs-vm-26`, `kv-ev-gr26-<id>`    |
   | snake_case | `-` niedozwolony, `_` dozwolony | `gal_labs_26` (Compute Gallery)       |
   | compact    | tylko `[a-z0-9]`                | `stevgr26<id>` (Storage Account, ACR) |

   Nie używamy CamelCase ani wielkich liter: nazwy w Azure są w większości niewrażliwe
   na wielkość liter (DNS), a narzędzia zwracają je w różnej postaci.
6. **Limity długości -- bez cichego obcinania.** `student_id` i `YY` są nietykalne. Jeśli pełna
   nazwa przekracza limit typu, moduł używa `workload_short`; jeśli skrótu brak albo też jest
   za długi, `tofu plan` kończy się błędem z listą nazw i ich długości.

Limity typów z nazwą zależną od `workload` (`student_id` = 13 znaków, `YY` = 2):

| Typ             | Wzorzec                   | Limit | Miejsce na `workload` |
|-----------------|---------------------------|-------|-----------------------|
| Storage Account | `st<workload>26<id>`      | 24    | 7                     |
| Key Vault       | `kv-<workload>26-<id>`    | 24    | 5                     |
| Function App    | `func-lab<NNN>-26-<id>`   | 60    | --                    |

## Wejścia i wyjścia

| Wejście          | Wymagane | Opis                                                    |
|------------------|----------|---------------------------------------------------------|
| `student_id`     | tak      | `g<grupa>k<podgrupa>n<6 cyfr indeksu>`                  |
| `lab`            | tak      | numer labu, trzy cyfry                                  |
| `workload`       | tak      | obciążenie w kebab-case                                 |
| `workload_short` | nie      | skrót, używany tylko gdy pełna nazwa przekracza limit   |
| `year`           | nie      | rok edycji, domyślnie `2026`                            |

Wyjścia: `year`, `yy`, `wl` (`lab<NNN>`), `tags`, `rg`, `common`, `names` (`st`, `kv`, `func`,
`plan`, `appi`).

## Rozwój i publikacja

```bash
tofu init && tofu test    # testy konwencji: tests/naming.tftest.hcl
```

Workflow `.github/workflows/publish.yaml`:

* push / pull request -- `fmt`, `validate`, `tofu test`, zbudowanie paczki `module.zip`
  (artefakt workflow);
* tag `vX.Y.Z` -- dodatkowo publikacja w `ghcr.io/<organizacja>/tf-naming:vX.Y.Z` (`oras push`,
  typ `application/vnd.opentofu.modulepkg`) i GitHub Release z paczką.

Po pierwszej publikacji pakiet trzeba jednorazowo ustawić jako publiczny (*Packages* ->
`tf-naming` -> *Package settings* -> *Change visibility*). Nowa edycja kursu: zmiana
`default` zmiennej `year` i nowa wersja główna.

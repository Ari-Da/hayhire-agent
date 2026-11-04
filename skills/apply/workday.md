# Workday applications

Workday forms (`*.myworkdayjobs.com`) differ from Greenhouse and Ashby. Read this with `profile.md`.

## Accounts and sign-in (user does this)
- Most Workday tenants need an account per company. Creating an account, entering a password or signing in is never done by Claude. The user signs in or registers, then gives Claude the tab already inside the application (steps like "My Information" or "My Experience").
- The user may use "Autofill with Resume" on the first step; Claude then checks and corrects what it filled.
- Claude never clicks Submit. Printouts: only when the user asks.

## Form-filling rules that worked
- Every dropdown and search field: click it, type the text, press Return to search, then press Return again (or click the option) to select. Always read back the selected value; a wrong first match is common (typing a school name often matches a different school).
- Plain Workday dropdowns ("Select One" lists): typing does not select. Click the dropdown, take a screenshot, then click the option in the open list and read it back (the page can shift, so never click saved coordinates; zoom on the field afterwards to verify). If a dropdown seems unresponsive, it may have toggled closed: click the field again once.
- Searchable "Field of Study" list: pressing Return selects the first fuzzy match ("Data Science" selected "Data Processing"); check the chip and remove it if wrong.
- Tab focus: after selecting a skill the focus moves into the list. Close the dropdown by clicking the blank page margin, then click the list icon to open the search again before typing the next skill.
- Verify with `get_page_text` at the end: it shows selected items ("15 items selected").


## Education and work history
- Fill every entry from `profile.md`. When a school is not in the list, leave it empty and tell the user instead of picking a different school.
- Some tenants keep only one education entry; tell the user which one was kept.

## Skills field (Workday multi-select)
- Use only real skills from the resume. Pick the plain term (e.g. "Docker", not "Docker Compose") and re-read the chips on the Review page.

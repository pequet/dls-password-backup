# New Project Checklist

This checklist provides the steps to initialize a new project from this boilerplate.

## 1. Project Setup & Attribution

- [ ] **Global Search & Replace:**
  - [ ] Perform a global search-and-replace for the following boilerplate-specific placeholders across the entire project:
    - [ ] `cursor-project-boilerplate` (kebab-case name)
    - [ ] `Cursor Project Boilerplate` (Title Case name)
    - [ ] `Benjamin Pequet` (Author name)
    - [ ] `pequet` (GitHub username and support link paths)
- [ ] **Rename Project Directory:**
  - [ ] Rename the root directory from `cursor-project-boilerplate` to your new project name.
- [ ] **Update `LICENSE`:**
  - [ ] Update the copyright year and holder name in the `LICENSE` file.
- [ ] **Configure `.gitignore`:**
  - [ ] Uncomment the following lines in your `.gitignore` file to exclude boilerplate-specific context from your new project's repository:
    ```
    # .cursor
    # .cursor/
    # inbox
    # inbox/
    # archives
    # archives/
    # memory-bank
    # memory-bank/
    ```

## 2. Configuration

- [ ] **Configure `vibe-tools`:**
  - [ ] Review `vibe-tools.config.json` and adjust the default models and settings if necessary.
  - [ ] Create a `~/.vibe-tools/.env` file and add your API keys for the AI providers you plan to use (e.g., `OPENAI_API_KEY`, `GEMINI_API_KEY`).
- [ ] **Review & Update Cursor Rules:**
  - [ ] Familiarize yourself with the rules in `.cursor/rules/`.
  - [ ] **Crucial:** Update `.cursor/rules/290-script-attribution-standards.mdc` with your own author, project, and link information. The script templates in this file will be incorrect until you do.
  - [ ] Modify or add other rules as needed for your project's specific requirements.

## 3. Initialize the memory-bank

Choose ONE of the following options:

**Option 1: Start with a clean slate**

- [ ] **Clear `memory-bank/`:**
  - [ ] Delete any files inside the `memory-bank/` directory to start with a clean slate. This will erase the boilerplate project history. You will lose the example notes and references in the files.
- [ ] **Clear other directories:**
  - [ ] Delete all files in the `inbox/` and `archives/` directories.
- [ ] **Create new files:**
  - [ ] Follow the structure in `.cursor/rules/210-memory-bank.mdc` to create your own memory bank files.

**Option 2: Start with the boilerplate's memory-bank (Recommended)**

- [ ] **Instruct the AI:**
  - [ ] Run the command `initialize memory bank` to have the AI verify the setup and guide you through customizing the content for your project.
- [ ] **Review all `memory-bank/` files:**
  - [ ] Read through the existing memory bank files to understand their purpose and structure.

## 4. Documentation Review

- [ ] **Review Boilerplate Docs:**
  - [ ] Read `docs/000-Framework-Context.md` to understand the philosophy behind this boilerplate.
  - [ ] Read `docs/010-Development-Workflow.md` for the suggested development workflow.
  - [ ] Update or remove these documents as they fit into your new project.
- [ ] **Review `PREFLIGHT.md`:**
  - [ ] Update the `PREFLIGHT.md` checklist to suit your project's deployment or release process.
- [ ] **Update `README.md`:**
  - [ ] Edit the `README.md` to describe your new project, removing boilerplate-specific information.


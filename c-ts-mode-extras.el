;;; c-ts-mode-extras.el --- Extra rules for c{++}-ts-mode -*- lexical-binding: t; -*-

;; Copyright (C) 2025 TideS

;; Author: TideS <tidesmain@gmail.com>
;; Keywords: convenience, languages
;; Package-Requires: ((emacs "30.1"))
;; Version: 1.0

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Code:

(eval-when-compile
  (require 'cl-lib))

(defgroup c-ts-mode-extras nil
  "Extra faces for tree-sitter."
  :group 'faces)

(defface c-ts-mode-extras-boolean-face
  '((t :inherit font-lock-constant-face :weight bold))
  "Custom face for tree-sitter. Used with 'true', 'false' keywords."
  :group 'font-lock-faces)

(defface c-ts-mode-extras-null-face
  '((t :inherit font-lock-builtin-face))
  "Custom face for tree-sitter. Used with 'NULL' or 'nullptr'."
  :group 'font-lock-faces)

(defface c-ts-mode-extras-this-face
  '((t :inherit font-lock-keyword-face))
  "Custom face for tree-sitter. Used with 'this' keywords."
  :group 'font-lock-faces)

(defface c-ts-mode-extras-return-face
  '((t :inherit font-lock-keyword-face))
  "Custom face for tree-sitter. Used with 'return' keywords."
  :group 'font-lock-faces)

(defface c-ts-mode-extras-enumerator-face
  '((t :inherit font-lock-constant-face))
  "Custom enumerator face for tree-sitter"
  :group 'font-lock-faces)

(defface c-ts-mode-extras-field-face
  '((t :inherit font-lock-property-name-face))
  "Custom field face for tree-sitter."
  :group 'font-lock-faces)

(defface c-ts-mode-extras-parameter-face
  '((t :inherit font-lock-variable-name-face))
  "Custom parameter face for tree-sitter."
  :group 'font-lock-faces)

(defface c-ts-mode-extras-named-operator-face
  '((t :inherit font-lock-keyword-face))
  "Custom named operator face for tree-sitter."
  :group 'font-lock-faces)

(defface c-ts-mode-extras-label-face
  '((t :inherit font-lock-keyword-face :weight semibold :slant normal))
  "Custom label face for C/C++ tree-sitter."
  :group 'font-lock-faces)

(defvar c-ts-mode-extras--constant-regex "\\`[A-Z_][A-Z0-9_]+\\'" "")

(use-package c-ts-mode
  :ensure nil
  :preface
  (defun c-ts-mode-extras--keywords (orig-fun &rest args)
    `("alignas" "_Alignas"
      "#if" "#ifdef" "#ifndef"
      "#elif" "#else" "#endif" "#define",@(apply orig-fun args)))
  (defconst c-ts-mode-extras--constants
    `(((field_identifier) @font-lock-constant-face
       (:match ,c-ts-mode-extras--constant-regex @font-lock-constant-face))
      ((identifier) @font-lock-constant-face
       (:match ,c-ts-mode-extras--constant-regex @font-lock-constant-face))))
  (defconst c-ts-mode-extras--common
    `(("." @font-lock-punctuation-face)

      (attribute_declaration) @font-lock-constant-face

      (parameter_declaration
       declarator:
       (identifier) @c-ts-mode-extras-parameter-face)
      (parameter_declaration
       declarator:
       (pointer_declarator
        declarator:
        (identifier) @c-ts-mode-extras-parameter-face))
      (parameter_declaration
       declarator:
       (pointer_declarator
        declarator:
        (pointer_declarator
         declarator:
         (identifier) @c-ts-mode-extras-parameter-face)))
      (parameter_declaration
       declarator:
       (pointer_declarator
        declarator:
        (pointer_declarator
         declarator:
         (pointer_declarator
          declarator:
          (identifier) @c-ts-mode-extras-parameter-face))))
      (parameter_declaration
       declarator:
       (function_declarator
        declarator:
        (parenthesized_declarator
         (_ declarator: (identifier) @c-ts-mode-extras-parameter-face))))

      (field_identifier) @c-ts-mode-extras-field-face

      (conditional_expression (["?" ":"]) @font-lock-keyword-face)

      [(true) (false)] @c-ts-mode-extras-boolean-face
      (null) @c-ts-mode-extras-null-face

      (char_literal "'" @font-lock-string-face)
      (char_literal (character) @font-lock-string-face)
      (escape_sequence) @c-ts-mode-extras-named-operator-face

      (case_statement value: (identifier) @font-lock-constant-face)

      (sizeof_expression "sizeof" @c-ts-mode-extras-named-operator-face)

      (alignas_qualifier (identifier) @font-lock-type-face)

      (labeled_statement label: (_) @c-ts-mode-extras-label-face)
      (goto_statement label: (_) @c-ts-mode-extras-label-face)

      ("return" @c-ts-mode-extras-return-face)

      (sized_type_specifier) @font-lock-builtin-face

      (primitive_type) @font-lock-builtin-face

      (enumerator
       name: (identifier) @c-ts-mode-extras-enumerator-face)))
  (defconst c-ts-mode-extras--preprocessor
    `(
      (call_expression
       function: (identifier) @font-lock-function-call-face)
      (call_expression
       function: (field_expression
                  field: (field_identifier) @font-lock-function-call-face))

      (preproc_call directive: (_) @font-lock-keyword-face)
      (preproc_defined
       "defined" @font-lock-function-call-face
       "(" @font-lock-punctuation-face
       (identifier) @font-lock-constant-face
       ")" @font-lock-punctuation-face)
      (preproc_def name: (_) @font-lock-constant-face)
      (preproc_function_def name: (_) @font-lock-function-name-face)
      (preproc_ifdef name: (_) @font-lock-constant-face)
      (preproc_params
       "(" @font-lock-punctuation-face
       (identifier) @c-ts-mode-extras-parameter-face
       ")" @font-lock-punctuation-face)))
  :config
  (setopt c-ts-mode--preproc-keywords '("#include"))
  (advice-add 'c-ts-mode--keywords :around #'c-ts-mode-extras--keywords)

  (push 'extras (nth 3 c-ts-mode--feature-list))
  (push 'extras-common (nth 3 c-ts-mode--feature-list))
  (push 'extras-preprocessor (nth 3 c-ts-mode--feature-list))
  (push 'extras-namespace-types (nth 3 c-ts-mode--feature-list))
  (push 'extras-namespace-functions (nth 3 c-ts-mode--feature-list))
  (push 'extras-fields (nth 3 c-ts-mode--feature-list))
  (push 'extras-constants (nth 3 c-ts-mode--feature-list))

  (defun c-ts-mode-extras--non-const-field (node)
    "Return non-nil if NODE is not a constant field identifier."
    (not (when-let* ((parent (treesit-node-parent node)))
           (cl-dolist (child (treesit-node-children parent t))
             (when (string-match-p "const" (treesit-node-text child))
               (cl-return t))))))

  (defun c-ts-mode-extras--fontlock-settings (mode)
    (let ((res '()))
      (add-to-list
       'res
       (car
        (treesit-font-lock-rules
         :language mode
         :override t
         :feature 'extras-common
         c-ts-mode-extras--common))
       t)
      (add-to-list
       'res
       (car
        (treesit-font-lock-rules
         :language mode
         :override t
         :feature 'extras-constants
         c-ts-mode-extras--constants))
       t)
      (add-to-list
       'res
       (car
        (treesit-font-lock-rules
         :language mode
         :override t
         :feature 'extras-fields
         `(
           (field_declaration
            declarator: (field_identifier) @c-ts-mode-extras-field-face
            (:pred
             c-ts-mode-extras--non-const-field
             @c-ts-mode-extras-field-face))

           (pointer_declarator
            declarator: (field_identifier) @c-ts-mode-extras-field-face
            (:pred
             c-ts-mode-extras--non-const-field
             @c-ts-mode-extras-field-face))

           (initializer_pair
            designator: (field_designator
                         (field_identifier) @c-ts-mode-extras-field-face))

           (field_expression
            field: (field_identifier) @c-ts-mode-extras-field-face))))
       t)
      (if (eq mode 'c)
          (progn
            (add-to-list
             'res
             (car
              (treesit-font-lock-rules
               :language 'c
               :override t
               :feature 'extras-preprocessor
               c-ts-mode-extras--preprocessor))
             t)
            (add-to-list
             'res
             (car
              (treesit-font-lock-rules
               :language 'c
               :override t
               :feature 'extras
               `((macro_type_specifier
                  name: (identifier) @font-lock-function-call-face))))
             t))
        (progn
          (add-to-list
           'res
           (car
            (treesit-font-lock-rules
             :language 'cpp
             :override t
             :feature 'extras-fields
             `((function_declarator
                declarator: ([(field_identifier) (identifier)])
                @font-lock-function-name-face)

               (field_declaration
                type: (placeholder_type_specifier (auto))
                declarator: (field_identifier)
                @font-lock-function-name-face))))
           t)
          (add-to-list
           'res
           (car (treesit-font-lock-rules
                 :language 'cpp
                 :override t
                 :feature 'extras-preprocessor
                 c-ts-mode-extras--preprocessor))
           t)
          (add-to-list
           'res
           (car
            (treesit-font-lock-rules
             :language 'cpp
             :override t
             :feature 'extras-namespace-types
             `((using_declaration (identifier) @font-lock-type-face)

               (using_declaration
                (qualified_identifier
                 scope: (namespace_identifier)
                 name: (identifier) @font-lock-type-face))

               (namespace_identifier) @font-lock-type-face

               (qualified_identifier
                scope: (namespace_identifier)
                name: (qualified_identifier
                       scope: (namespace_identifier)
                       name: (identifier)  @font-lock-type-face)))))
           t)
          (add-to-list
           'res
           (car
            (treesit-font-lock-rules
             :language 'cpp
             :override t
             :feature 'extras-namespace-functions
             `((call_expression
                function:
                (qualified_identifier
                 scope: (namespace_identifier)
                 name: (identifier) @font-lock-function-call-face))

               (function_declarator
                declarator:
                (qualified_identifier
                 scope: (namespace_identifier)
                 name: (identifier) @font-lock-function-name-face)))))
           t)
          (add-to-list
           'res
           (car
            (treesit-font-lock-rules
             :language 'cpp
             :override t
             :feature 'extras
             '((declaration
                declarator:
                (function_declarator
                 declarator: (identifier) @font-lock-function-name-face))

               (parameter_declaration
                declarator: (_ (identifier) @c-ts-mode-extras-parameter-face))

               ((this) @c-ts-mode-extras-this-face)

               (operator_name "[]" @font-lock-operator-face)

               (concept_definition name: (_) @font-lock-type-face)

               (template_function
                name: (identifier) @font-lock-function-name-face)

               (new_expression "new" @c-ts-mode-extras-named-operator-face)

               (delete_expression "delete" @c-ts-mode-extras-named-operator-face)

               (function_definition
                type:
                (type_identifier) @font-lock-keyword-face
                (:match "\\`compl\\'" @font-lock-keyword-face))

               (template_parameter_list (["<" ">"]) @font-lock-punctuation-face)
               (template_parameter_list
                (parameter_declaration
                 declarator: (_) @c-ts-mode-extras-parameter-face))

               (template_argument_list (["<" ">"]) @font-lock-punctuation-face)
               (template_argument_list
                (type_descriptor
                 type: (type_identifier) @font-lock-type-face))

               (template_type name: (type_identifier) @font-lock-type-face)

               ("::" @font-lock-punctuation-face)

               (call_expression
                function:
                (qualified_identifier
                 name:
                 (qualified_identifier
                  name: (identifier) @font-lock-function-call-face)))
               (call_expression
                function: (qualified_identifier
                           scope: (namespace_identifier)
                           name: (identifier) @font-lock-function-call-face))
               (call_expression
                function: (template_function
                           name: (identifier) @font-lock-function-call-face)))))
           t)))
      res))

  (defconst c-ts-mode-extras--fontlock-settings-c
    (c-ts-mode-extras--fontlock-settings 'c))

  (defconst c-ts-mode-extras--fontlock-settings-cpp
    (c-ts-mode-extras--fontlock-settings 'cpp))

  (defun c-ts-mode-extras--fontlock-settings-wrapper (orig-fun
                                                      &rest
                                                      args)
    (let ((res (apply orig-fun args)))
      (if (eq (car args) 'c)
          (append res c-ts-mode-extras--fontlock-settings-c)
        (append res c-ts-mode-extras--fontlock-settings-cpp))))
  (advice-add 'c-ts-mode--font-lock-settings
              :around
              #'c-ts-mode-extras--fontlock-settings-wrapper))

(provide 'c-ts-mode-extras)
;;; c-ts-mode-extras.el ends here

;;; helm-tree-sitter-cpp.el --- Helm interface for tree-sitter -*- lexical-binding: t -*-

;; Copyright (C) 2021 Giedrius Jonikas <giedriusj1@gmail.com>

;; Author: Giedrius Jonikas <giedriusj1@gmail.com>
;; Version: 0.1.0
;; URL: https://gitlab.com/giedriusj1/helm-tree-sitter

;; Package-Requires: ((emacs "25.1") (helm "3.6.2") (tree-sitter "0.16.1"))

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;; Provides function for dealing with C++ code

;;; Code:

(defvar helm-tree-sitter-cpp-candidate-producer
  '(
    ;; We'll borrow some function from C
    ("preproc_include"     . helm-tree-sitter-c-preproc-include-fn)
    ("enum_specifier" . helm-tree-sitter-c-enum-specifier-fn)
    ("union_specifier" . helm-tree-sitter-c-union-specifier-fn)

    ;; Stuff that is unique for C++
    ("function_definition" . helm-tree-sitter-cpp-function-definition-fn)
    ("class_specifier"     . helm-tree-sitter-cpp-class-specifier-fn)


    ;; We get very spammy output if we try to show every declaration,
    ;; so we'll just ignore them for now.
    ;; ("declaration" . helm-tree-sitter-cpp-declaration-fn)
    ))

(defun helm-tree-sitter-cpp-function-definition-fn (x)
  (unless (helm-tree-sitter-elem-p x)
    (signal 'wrong-type-argument (list 'helm-tree-sitter-elem-p x)))

  (let* ((children-alist (helm-tree-sitter-node-children-to-alist (helm-tree-sitter-elem-node x)))
         ;; Let's get the return type of the function.
         ;; Only one kind will be present.

         ;; Something like boost::shared_ptr<type> fn()
         (template-type (helm-tree-sitter-get-node-text-or-nil (alist-get 'template_type children-alist)))

         ;; We would have this with namespace::type fn()
         (scoped-type (helm-tree-sitter-get-node-text-or-nil (alist-get 'scoped_type_identifier children-alist)))

         ;; We would have this with type fn()
         (type-identifier (helm-tree-sitter-get-node-text-or-nil (alist-get 'type_identifier children-alist)))

         ;; We would have this with int fn()
         (primitive-type (helm-tree-sitter-get-node-text-or-nil (alist-get 'primitive_type children-alist)))

         (function-declarator (helm-tree-sitter-get-node-text (alist-get 'function_declarator children-alist)))
         (function-reference-declarator (helm-tree-sitter-get-node-text (alist-get 'reference_declarator children-alist)))
         (function-pointer-declarator (helm-tree-sitter-get-node-text (alist-get 'pointer_declarator children-alist))))

    (concat
     (propertize "Function / "
                 'face 'italic)

     (concat
      (let* ((type (or template-type
                       scoped-type
                       type-identifier
                       primitive-type)))
        (if type
            (concat type " ")))

      function-pointer-declarator
      function-reference-declarator
      function-declarator))))



(defun helm-tree-sitter-cpp-class-specifier-fn (x)
  (unless (helm-tree-sitter-elem-p x)
    (signal 'wrong-type-argument (list 'helm-tree-sitter-elem-p x)))

  (let* ((children-alist (helm-tree-sitter-node-children-to-alist (helm-tree-sitter-elem-node x)))
         (type-identifier (helm-tree-sitter-get-node-text (alist-get 'type_identifier children-alist))))

    (concat
     (propertize "Class specifier / "
                 'face 'italic)
     type-identifier)))

(provide 'helm-tree-sitter-cpp)

;;; helm-tree-sitter-cpp.el ends here
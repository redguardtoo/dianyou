;;; dianyou.el --- Search/Analyze mails in Gnus

;; Copyright (C) 2019 Chen Bin
;;
;; Version: 0.0.1
;; Keywords: email
;; Author: Chen Bin <chenbin DOT sh AT gmail DOT com>
;; URL: http://github.com/usrname/dianyou
;; Package-Requires: ((emacs "24.4"))

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;;; Commentary:

;; `dianyou-group-make-nnir-group' to search mails.

;;; Code:
(require 'gnus-group)
(require 'gnus-util)

(defun dianyou-read-params (x)
  (let* ((rlt (nnir-read-parms (nnir-server-to-search-engine (car x)))))
    (message "rlt=%s" rlt)
    rlt))

(defun dianyou-group-make-nnir-group ()
  "Create an nnir group.  Prompt for a search query and determine
the groups to search as follows: if called from the *Server*
buffer search all groups belonging to the server on the current
line; if called from the *Group* buffer search any marked groups,
or the group on the current line, or all the groups under the
current topic. Calling with a prefix-arg prompts for additional
search-engine specific constraints."
  (interactive)
  (let* ((group-spec (if (gnus-server-server-name)
                         (list (list (gnus-server-server-name)))
                       (nnir-categorize
                        (or gnus-group-marked
                            (if (gnus-group-group-name)
                                (list (gnus-group-group-name))
                              (cdr (assoc (gnus-group-topic-name) gnus-topic-alist))))
                        gnus-group-server)))
         (query-spec (apply
                      'append
                      (list (cons 'query
                                  (read-string "Query: " nil 'nnir-search-history)))
                      (mapcar #'dianyou-read-params group-spec))))
    (gnus-group-read-ephemeral-group
     (concat "nnir-" (message-unique-id))
     (list 'nnir "nnir")
     nil
     nil
     nil
     nil
     (list
      (cons 'nnir-specs (list (cons 'nnir-query-spec query-spec)
                              (cons 'nnir-group-spec group-spec)))
      (cons 'nnir-artlist nil)))))
(provide 'dianyou)
;;; dianyou.el ends here


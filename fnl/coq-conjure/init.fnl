(require-macros :macros)
(require! {conjure-eval conjure.eval conjure-promise conjure.promise})

(local conjure-source {:timer nil :promise-id nil})

(fn map [f ls]
  (icollect [_ v (ipairs ls)]
    (f v)))

(fn split-line [line col]
  (vim.validate {:line [line :string] :col [col :number]})
  (let [c (math.min (math.max 0 col) (length line))
        lhs (string.sub line 1 c)
        rhs (string.sub line (+ c 1))]
    [lhs rhs]))

(fn conjure-item->lsp-item [c-item]
  {:label c-item.word
   :kind (match c-item.kind
           :F vim.lsp.protocol.CompletionItemKind.Function
           :M vim.lsp.protocol.CompletionItemKind.Function)
   :detail c-item.info})

(fn should-call [m]
  (and (= vim.bo.filetype :clojure) (not= m nil) (> (length m) 0)))

(fn abort []
  (let [{: promise-id : timer} conjure-source]
    (if timer
        (do
          (timer:stop)
          (timer:close)
          (tset conjure-source :timer nil)))
    (if promise-id
        (conjure-promise:close promise-id))))

(fn complete-task [promise-id callback]
  (vim.schedule_wrap (fn []
                       (when (conjure-promise.done? promise-id)
                         (callback {:items (map conjure-item->lsp-item
                                                (conjure-promise.close promise-id))})
                         (abort)))))

(fn complete [m callback]
  (abort)
  (tset conjure-source :promise-id ((. conjure-eval :completions-promise) m))
  (tset conjure-source :timer (vim.loop.new_timer))
  (let [{: promise-id : timer} conjure-source]
    (timer:start 100 100 (complete-task promise-id callback))))

(local conjure-regex "[0-9a-zA-Z.!$%&*+/:<=>?#_~\\^\\-\\\\]\\+$")

(local conjure-source-config
       {:name :Conjure
        :fn (fn [args callback]
              (let [[_ col] args.pos
                    [before-cursor _] (split-line args.line col)
                    m (vim.fn.matchstr before-cursor conjure-regex)]
                (if (should-call m)
                    (complete m callback)
                    (callback nil))))})

(fn register []
  (global COQsources (or COQsources {}))
  (tset COQsources 1000 conjure-source-config))

{: register}

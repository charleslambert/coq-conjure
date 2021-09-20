(fn require! [deps]
  (local names (list))
  (local reqss [])
  (each [k v (pairs deps)]
    (let [mod-name (tostring v)]
      (table.insert names k)
      (table.insert reqss `(require ,mod-name))))
  (local reqs (list (sym :unpack) reqss))
  `(local ,names ,reqs))

{: require!}

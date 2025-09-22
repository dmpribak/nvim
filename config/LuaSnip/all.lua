-- local s = require("luasnip").snippet
return {
    s({trig="def", snippetType="autosnippet"},
        fmt(
            [[
                def {1}({2}) -> {3}:
                    """
                    Function description.

                    Parameters
                    ----------

                    Returns
                    -------
                    out : {}
                    """

                    
            ]],
            {
                i(1, "funcname"), 
                i(2, "args"),
                -- d(2, function(args)
                --         return sn(3, 
                --                     [[{}:{}]], 
                --                     {i(1), i(2)}
                --                 )
                --         end
                -- ),
                i(3, "ret_type"), 
                rep(3)
            }
        )
    ),
}

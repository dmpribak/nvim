-- local s = require("luasnip").snippet
return {
    s({trig="def", snippetType="autosnippet"},
        fmt(
            [[
                def {}({}) -> {3}:
                    """
                    Function description.

                    Parameters
                    ----------
                    {} : {}
                        {}

                    Returns
                    -------
                    out : {}
                    """

                    
            ]],
            {
                i(1, "funcname"), 
                d(2, function(args)
                        return sn(3, 
                                    [[{}:{}]], 
                                    {i(1), i(2)}
                                )
                        end
                ),
                i(3, "ret_type"), 
                rep(1), 
                rep(1), 
                i(5, "arg1_desc"), 
                rep(3)
            }
        )
    )
}

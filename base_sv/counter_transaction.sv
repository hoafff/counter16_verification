class counter_transaction;
    bit enable;

    function new(bit enable = 1'b0);
        this.enable = enable;
    endfunction

    function string sprint();
        return $sformatf("enable=%0b", enable);
    endfunction
endclass

class counter_sample;
    bit          reset;
    bit          enable;
    logic [15:0] count;

    function string sprint();
        return $sformatf("reset=%0b enable=%0b count=0x%04h", reset, enable, count);
    endfunction
endclass

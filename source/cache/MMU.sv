`include "common.svh"

module MMU (
    input logic clk,resetn,

    input dbus_req_t dreq,
    input ibus_req_t ireq,

    output dbus_resp_t dresp, 
    output ibus_resp_t iresp,

    output dbus_req_t cache_dreq,
    output ibus_req_t cache_ireq,  //translated ireq

    input dbus_resp_t cache_dresp,
    input ibus_resp_t cache_iresp,

    //output logic d_uncached 
    output logic i_uncached,d_uncached
);


/*ibus_resp_t cache_iresp, iresp;
ibus_req_t ireq;
logic i_uncached;
dbus_resp_t dresp;*/

logic d_skid_free;
dbus_req_t d_skid_buffer;


dbus_req_t t_dreq;
ibus_req_t t_ireq;

assign cache_dreq = d_skid_free ? t_dreq : d_skid_buffer ;
assign cache_ireq = t_ireq;

assign iresp = cache_iresp;

always_comb begin
    dresp = cache_dresp;
    dresp.addr_ok = dreq.valid?d_skid_free:1'b0;
end

TU TU_inst(.*);   // Translation Unit

always_ff @(posedge clk) begin
    if(resetn) begin
        if(cache_dresp.addr_ok) begin
            d_skid_buffer<='0;
            d_skid_free<=1'b1;
        end
        else if(dreq.valid && d_skid_free) begin
            d_skid_free  <=1'b0;
            d_skid_buffer<=t_dreq;
        end
    end
    else begin
        d_skid_free<=1'b1;
        d_skid_buffer<='0;
    end
end

    
endmodule
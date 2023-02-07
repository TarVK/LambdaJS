const setupFromURL = ()=>{
    const params = new URLSearchParams(location.search);
    setup(JSON.parse(params.get("constructors")), params.get("func"));
};

function setup(constructors, code){
    const func = eval(code);
    const {encode, decode} = createConverters(constructors, "exec", func);
    window.encode = encode;
    window.decode = decode;
    window.func = func;
}

function copyToClipBoard(text) {
    var inp = document.createElement('textarea');
    document.body.appendChild(inp)
    inp.value = text;
    inp.select();
    document.execCommand('copy', false);
    inp.remove();
}

setupFromURL();
window.addEventListener('locationchange', setupFromURL);
const cons = $(".console").console({
    mode: "text",
    onInput(text){
        try {
            const result = encode(text);
            this.output(new this.PlainText(decode(result)));
        } catch (e) {
            this.error(e);
        }
    },
    onRightClick(obj){
        console.log(obj);
        copyToClipBoard(obj.data);
        this.inf("Data has been copied to clipboard");
    }
});
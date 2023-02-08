

const setupFromURL = ()=>{
    const paramsList = location.search.substring(1).split("&");
    const paramsRelation = paramsList.map(p=>{
        const parts = p.split("=");
        return [parts[0], decodeURI(parts.slice(1).join("="))];
    });
    const paramsMap = Object.fromEntries(paramsRelation);
    setup(JSON.parse(paramsMap["constructors"]), paramsMap["func"]);
};

function setup(constructors, code){
    const func = eval(code);
    const {encode, decode} = createConverters(constructors, "exec", func);
    window.encode = encode;
    window.decode = decode;
    window.func = func;
    
    showFunction(code);
}

function copyToClipBoard(text) {
    var inp = document.createElement('textarea');
    document.body.appendChild(inp)
    inp.value = text;
    inp.select();
    document.execCommand('copy', false);
    inp.remove();
}

function showFunction(code) {
    const div = $("<div class=code></div>")[0];

    const funcEditor = ace.edit(div);
    funcEditor.setTheme("ace/theme/xcode");
    funcEditor.getSession().setMode("ace/mode/javascript");
    funcEditor.getSession().setUseWrapMode(true);
    funcEditor.getSession().setUseSoftTabs(true);
    funcEditor.setShowPrintMargin(false);
    funcEditor.setOptions({ maxLines: 20.5, fontSize: "10px" });
    funcEditor.$blockScrolling = Infinity;
    funcEditor.renderer.setShowGutter(false);
    funcEditor.setReadOnly(true);
    funcEditor.renderer.$cursorLayer.element.style.display = "none";
    funcEditor.setValue(code, -1);

    cons.info("Loaded lambda calculus function:")
    cons.$print("", new cons.HtmlElement(div));

    const controls = $('<div class=codeControls><button class="copy">Copy code</button><button class="share">Share page</button></div>');
    controls.find(".copy").on("click", ()=>{
        copyToClipBoard(code);
        cons.info("Code copied to clipboard!");
    });
    controls.find(".share").on("click", ()=>{
        copyToClipBoard(location);
        cons.info("Url copied to clipboard!");
    });

    cons.$print("", new cons.HtmlElement(controls));
}

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

try {
    setupFromURL();
    
    cons.info("Type 'exec' followed by the (constructor) arguments to execute the exported function");
    window.addEventListener('locationchange', setupFromURL);
} catch (e) {
    cons.error("Failed to load the code");
    cons.error(e);
}
const React = globalRequire("index");
function App() {
    return (
        <div>
            <h1>Stateless App</h1>
            <p>This app does not use any React state.</p>
        </div>
    );
}

console.log(
    JSON.stringify(
        App()
    )
)
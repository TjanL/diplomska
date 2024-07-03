import useDeploymentStore from "./store"

function App() {
  const count = useDeploymentStore(state => state.count)

  return (
    <div className="flex justify-center items-center h-screen">
      <div className="text-center">
        <div className="font-semibold text-xl">App has been deployed</div>
        <div className="font-bold font-mono text-9xl">{count}<span className="text-6xl">x</span></div>
        <div className="text-neutral-400 text-xs">{import.meta.env.VITE_COMMIT}</div>
      </div>
    </div>
  )
}

export default App

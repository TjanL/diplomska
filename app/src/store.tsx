import { create } from 'zustand'
import { Configuration, DefaultApi } from './client'

interface DeploymentState {
    count: number
    fetch: () => void
}

const api = new DefaultApi(new Configuration({
    basePath: import.meta.env.API_HOST || "http://localhost:8000"
}))

const useDeploymentStore = create<DeploymentState>(set => ({
    count: 0,
    fetch: async () => {
        api.countApiCountGet().then(response => {
            set({ count: response.count })
        })
    },
}))

useDeploymentStore.getState().fetch()

export default useDeploymentStore

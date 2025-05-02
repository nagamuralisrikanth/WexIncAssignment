import { LightningElement, track } from 'lwc';
import createProjectHierarchy from '@salesforce/apex/ProjectService.createProjectHierarchy';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ProjectManager extends LightningElement {
    uidCounter = 1;

    @track project = { name: '' };
    @track milestones = [
        {
            uid: 1,
            name: '',
            dueDate: '',
            todos: [{ name: '', dueDate: '', uid: 1 }]
        }
    ];

    handleProjectChange(event) {
        this.project.name = event.target.value;
    }

    handleMilestoneChange(event) {
        const index = event.target.dataset.index;
        this.milestones[index].name = event.target.value;
    }

    handleMilestoneDateChange(event) {
        const index = event.target.dataset.index;
        this.milestones[index].dueDate = event.target.value;
    }

    handleTodoChange(event) {
        const mIndex = event.target.dataset.milestoneindex;
        const tIndex = event.target.dataset.todoindex;
        this.milestones[mIndex].todos[tIndex].name = event.target.value;
    }

    handleTodoDateChange(event) {
        const mIndex = event.target.dataset.milestoneindex;
        const tIndex = event.target.dataset.todoindex;
        this.milestones[mIndex].todos[tIndex].dueDate = event.target.value;
    }

    addMilestone() {
        this.milestones.push({
            uid: ++this.uidCounter,
            name: '',
            dueDate: '',
            todos: [{ name: '', dueDate: '', uid: Date.now() }]
        });
    }

    addTodo(event) {
        const index = event.target.dataset.index;
        this.milestones[index].todos.push({ name: '', dueDate: '', uid: Date.now() });
    }

    handleSubmit() {
        createProjectHierarchy({
            projectJSON: JSON.stringify(this.project),
            milestoneJSON: JSON.stringify(this.milestones)
        })
        .then(() => {
            this.showToast('Success', 'Project created successfully', 'success');
        })
        .catch((error) => {
            let msg = error?.body?.message || JSON.stringify(error);
            this.showToast('Error', msg, 'error');
            console.error('Apex Error:', error);
        });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}

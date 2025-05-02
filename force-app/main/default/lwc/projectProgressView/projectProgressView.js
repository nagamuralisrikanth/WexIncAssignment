import { LightningElement, api, wire, track } from 'lwc';
import getProjectWithMilestones from '@salesforce/apex/ProjectService.getProjectWithMilestones';

export default class ProjectProgressView extends LightningElement {
    @api recordId;
    @track project;
    @track milestones = [];

    @wire(getProjectWithMilestones, { projectId: '$recordId' })
    wiredProject({ error, data }) {
        if (data) {
            this.project = {
                name: data.Name,
                percent: data.Percent_Complete__c
            };
            this.milestones = data.Milestones__r?.map(m => ({
                id: m.Id,
                name: m.Name,
                percent: m.Percent_Complete__c
            })) || [];
        } else if (error) {
            console.error('Error fetching project:', error);
        }
    }
}

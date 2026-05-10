const app = document.getElementById('app');
const closeBtn = document.getElementById('closeBtn');

const badgeText = document.getElementById('badgeText');
const headerTitle = document.getElementById('headerTitle');
const headerSubtitle = document.getElementById('headerSubtitle');
const footerNote = document.getElementById('footerNote');

const citizenName = document.getElementById('citizenName');
const citizenId = document.getElementById('citizenId');
const currentJob = document.getElementById('currentJob');
const currentGrade = document.getElementById('currentGrade');

const brandVersion = document.getElementById('brandVersion');
const brandLink = document.getElementById('brandLink');

const sectionTitle = document.getElementById('sectionTitle');

const identityGrid = document.getElementById('identityGrid');
const permitsGrid = document.getElementById('permitsGrid');
const recordsList = document.getElementById('recordsList');
const licenseSummary = document.getElementById('licenseSummary');

const confirmModal = document.getElementById('confirmModal');
const confirmTitle = document.getElementById('confirmTitle');
const confirmDescription = document.getElementById('confirmDescription');
const confirmFee = document.getElementById('confirmFee');
const cancelConfirm = document.getElementById('cancelConfirm');
const acceptConfirm = document.getElementById('acceptConfirm');
const modalError = document.getElementById('modalError');

let state = null;
let pendingAction = null;

function formatMoney(value) {
    const number = Number(value) || 0;

    return '$' + number.toLocaleString('en-US', {
        maximumFractionDigits: 0
    });
}

function iconEmoji(icon) {
    const map = {
        'id-card': '🪪',
        car: '🚗',
        shield: '🛡️',
        briefcase: '💼',
        crosshair: '🎯',
        fish: '🎣',
        'file-signature': '📄',
        user: '👤',
        trash: '🗑️',
        taxi: '🚕',
        bus: '🚌',
        'truck-pickup': '🛻',
        box: '📦',
        utensils: '🍴',
        'address-card': '🪪',
        'clipboard-check': '📋'
    };

    return map[icon] || '🏛️';
}

function postNui(name, data = {}) {
    return fetch(`https://${GetParentResourceName()}/${name}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify(data)
    }).then((response) => response.json());
}

function closeUI() {
    app.classList.add('hidden');
    confirmModal.classList.add('hidden');
    pendingAction = null;
}

function openUI(data) {
    state = data;

    const text = data.text || {};

    badgeText.textContent = text.badgeText || 'Official Civic Portal';
    headerTitle.textContent = text.headerTitle || 'San Andreas City Hall';
    headerSubtitle.textContent = text.headerSubtitle || 'Government Services Division';
    footerNote.textContent = text.footerNote || 'All services are logged and processed through city records.';

    const meta = data.meta || {};
    brandVersion.textContent = meta.version ? `v${meta.version}` : '';
    if (meta.repo) {
        brandLink.href = meta.repo;
        brandLink.style.display = '';
    } else {
        brandLink.style.display = 'none';
    }

    const citizen = data.citizen || {};
    const job = citizen.currentJob || {};

    citizenName.textContent = citizen.name || 'Unknown Citizen';
    citizenId.textContent = citizen.citizenId || 'Unknown';
    currentJob.textContent = job.label || 'Unemployed';
    currentGrade.textContent = job.gradeLabel || 'Civilian';

    renderIdentity();
    renderPermits();
    renderRecords();

    showTab('identity');

    app.classList.remove('hidden');
}

function renderIdentity() {
    identityGrid.innerHTML = '';

    (state.identity || []).forEach((service) => {
        identityGrid.appendChild(createServiceCard({
            title: service.label,
            description: service.description,
            icon: service.icon,
            price: service.price,
            active: service.active,
            buttonText: service.active ? 'Issued' : 'Purchase',
            disabled: service.active,
            onClick: () => openConfirm({
                type: 'service',
                serviceType: 'identity',
                serviceId: service.id,
                title: service.label,
                description: service.description,
                fee: service.price
            })
        }));
    });
}

function renderPermits() {
    permitsGrid.innerHTML = '';

    (state.permits || []).forEach((service) => {
        permitsGrid.appendChild(createServiceCard({
            title: service.label,
            description: service.description,
            icon: service.icon,
            price: service.price,
            active: service.active,
            buttonText: service.active ? 'Approved' : 'Apply',
            disabled: service.active,
            onClick: () => openConfirm({
                type: 'service',
                serviceType: 'permit',
                serviceId: service.id,
                title: service.label,
                description: service.description,
                fee: service.price
            })
        }));
    });
}

function renderRecords() {
    recordsList.innerHTML = '';
    licenseSummary.innerHTML = '';

    const entries = state.records && state.records.entries ? state.records.entries : [];

    entries.forEach((entry) => {
        const row = document.createElement('div');
        row.className = 'record-row';

        row.innerHTML = `
            <h3>${iconEmoji(entry.icon)} ${entry.label}</h3>
            <p>${entry.description}</p>
        `;

        recordsList.appendChild(row);
    });

    [...(state.identity || []), ...(state.permits || [])].forEach((service) => {
        const row = document.createElement('div');
        row.className = 'license-row';

        row.innerHTML = `
            <span>${service.label}</span>
            <strong class="${service.active ? 'yes' : 'no'}">${service.active ? 'Active' : 'Inactive'}</strong>
        `;

        licenseSummary.appendChild(row);
    });
}

function createServiceCard(data) {
    const card = document.createElement('article');
    card.className = 'service-card';

    const priceText = data.priceIsText ? data.price : formatMoney(data.price);

    card.innerHTML = `
        <div>
            <div class="service-top">
                <div class="service-icon">${iconEmoji(data.icon)}</div>
                <span class="status-pill ${data.active ? 'active' : ''}">
                    ${data.active ? 'Active' : 'Available'}
                </span>
            </div>

            <h3>${data.title}</h3>
            <p>${data.description}</p>
        </div>

        <div class="service-bottom">
            <span class="price">${priceText}</span>
            <button class="primary-btn" ${data.disabled ? 'disabled' : ''}>${data.buttonText}</button>
        </div>
    `;

    const button = card.querySelector('button');

    if (!data.disabled) {
        button.addEventListener('click', data.onClick);
    }

    return card;
}

function showTab(tabName) {
    document.querySelectorAll('.tab').forEach((tab) => {
        tab.classList.toggle('active', tab.dataset.tab === tabName);
    });

    document.querySelectorAll('.panel').forEach((panel) => {
        panel.classList.remove('active');
        panel.scrollTop = 0;
    });

    const titleMap = {
        identity: 'Identification Services',
        permits: 'Permits & Applications',
        records: 'Citizen Records'
    };

    sectionTitle.textContent = titleMap[tabName] || 'City Hall';

    const panel = document.getElementById(`${tabName}Panel`);

    if (panel) {
        panel.classList.add('active');
    }
}

function openConfirm(action) {
    pendingAction = action;
    modalError.textContent = '';

    confirmTitle.textContent = action.title;
    confirmDescription.textContent = action.description || 'Confirm this government service.';
    confirmFee.textContent = formatMoney(action.fee || 0);

    confirmModal.classList.remove('hidden');
}

function closeConfirm() {
    confirmModal.classList.add('hidden');
    pendingAction = null;
    modalError.textContent = '';
}

function setModalBusy(isBusy) {
    acceptConfirm.disabled = isBusy;
    cancelConfirm.disabled = isBusy;
}

async function submitPendingAction() {
    if (!pendingAction) return;

    modalError.textContent = '';
    setModalBusy(true);

    try {
        let result;

        if (pendingAction.type === 'service') {
            result = await postNui('purchaseService', {
                serviceType: pendingAction.serviceType,
                serviceId: pendingAction.serviceId
            });
        }

        if (!result || !result.success) {
            modalError.textContent = result && result.message ? result.message : 'Request failed.';
            setModalBusy(false);
            return;
        }

        closeConfirm();

        const fresh = await postNui('refreshData');

        if (fresh && fresh.success) {
            openUI(fresh);
        }
    } catch (error) {
        modalError.textContent = 'NUI request failed.';
    }

    setModalBusy(false);
}

window.addEventListener('message', (event) => {
    const payload = event.data;

    if (!payload || !payload.action) return;

    if (payload.action === 'open') {
        openUI(payload.data || {});
    }

    if (payload.action === 'close') {
        closeUI();
    }
});

document.querySelectorAll('.tab').forEach((tab) => {
    tab.addEventListener('click', () => {
        showTab(tab.dataset.tab);
    });
});

closeBtn.addEventListener('click', () => {
    postNui('close').then(closeUI);
});

cancelConfirm.addEventListener('click', closeConfirm);
acceptConfirm.addEventListener('click', submitPendingAction);

document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') {
        if (!confirmModal.classList.contains('hidden')) {
            closeConfirm();
            return;
        }

        postNui('close').then(closeUI);
    }
});
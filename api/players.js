// Vercel serverless proxy. Sleeper player catalog is not a live scoring feed.
export default async function handler(req,res){
  res.setHeader('Cache-Control','s-maxage=21600, stale-while-revalidate=86400');
  try{
    const upstream=await fetch('https://api.sleeper.app/v1/players/nfl',{signal:AbortSignal.timeout(18000)});
    if(!upstream.ok)throw new Error('Sleeper unavailable');
    const raw=await upstream.json();
    const players=Object.entries(raw).filter(([,p])=>p && ['QB','RB','WR','TE'].includes(p.position) && (p.active || p.team)).map(([id,p])=>({id,name:p.full_name || [p.first_name,p.last_name].filter(Boolean).join(' '),team:p.team||'FA',position:p.position,age:p.age??null,status:p.status||'',number:p.number??null})).filter(p=>p.name);
    res.status(200).json({players,source:'Sleeper',updatedAt:new Date().toISOString()});
  }catch(e){res.status(503).json({error:'Player feed unavailable',players:[]});}
}
